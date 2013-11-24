require 'test_helper'
 
# Tests validation relating to url() references
class StyleParsingTest < ActiveSupport::TestCase

	test "bracket in comment is allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			/* { */ * { color: red; }
		END_OF_STRING
		assert style.valid?, "#{style.errors.full_messages}"
	end

	test "bracket in attribute selector is allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			*[href="{"] { color: red; }
		END_OF_STRING
		assert style.valid?, "#{style.errors.full_messages}"
	end

	test "parser fail is found" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			a { color: red; }}
		END_OF_STRING
		assert !style.valid?
	end

	test "parse moz doc" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document domain(google.com) { * { color: blue; } }
		END_OF_STRING
		sections = style.style_code.parse_moz_docs
		assert sections.length == 1, sections.length
		assert sections[0][:rules].length == 1, sections[0][:rules].length
		assert sections[0][:rules][0].rule_type == 'domain'
		assert sections[0][:rules][0].value == 'google.com'
		assert sections[0][:code] == '* { color: blue; }', sections[0][:code]
	end

	test "parse moz doc minimal spaces" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document domain(google.com){*{color:blue;}}
		END_OF_STRING
		sections = style.style_code.parse_moz_docs
		assert sections.length == 1, sections.length
		assert sections[0][:rules].length == 1, sections[0][:rules].length
		assert sections[0][:rules][0].rule_type == 'domain'
		assert sections[0][:rules][0].value == 'google.com'
		assert sections[0][:code] == '*{color:blue;}', sections[0][:code]
	end


	test "parse moz doc regexp with curly bracket" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document regexp("a{2}") { * { color: blue; } }
		END_OF_STRING
		sections = style.style_code.parse_moz_docs
		assert sections.length == 1, sections.length
		assert sections[0][:rules].length == 1, "#{sections[0][:rules].length} from #{sections}"
		assert sections[0][:rules][0].rule_type == 'regexp'
		assert sections[0][:rules][0].value == 'a{2}', sections[0][:rules][0].value
		assert sections[0][:code] == '* { color: blue; }', sections[0][:code]
	end

	test "parse moz doc regexp with curly bracket and comma" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document regexp("a{2,3}") { * { color: blue; } }
		END_OF_STRING
		sections = style.style_code.parse_moz_docs
		assert sections.length == 1, sections.length
		assert sections[0][:rules].length == 1, sections[0][:rules].length
		assert sections[0][:rules][0].rule_type == 'regexp'
		assert sections[0][:rules][0].value == 'a{2,3}', sections[0][:rules][0].value
		assert sections[0][:code] == '* { color: blue; }', sections[0][:code]
	end

end
