require 'test_helper'
 
class StyleParsingTest < ActiveSupport::TestCase

	test 'basic' do
		sections = Style.parse_moz_docs_for_code("@-moz-document domain(example.com) {* { color: blue; }}")
		assert_equal 1, sections.size
		assert !sections.first.global
		assert_equal 1, sections.first.style_section_rules.size
		assert_equal 'domain', sections.first.style_section_rules.first.rule_type
		assert_equal 'example.com', sections.first.style_section_rules.first.rule_value
		assert_equal '* { color: blue; }', sections.first.css
	end

	test 'multiple blocks' do
		sections = Style.parse_moz_docs_for_code("@-moz-document domain(example.com) {a { color: blue; }}@-moz-document domain(example.net) {b { color: red; }}")
		assert_equal 2, sections.size
		assert !sections.first.global
		assert_equal 1, sections.first.style_section_rules.size
		assert_equal 'domain', sections.first.style_section_rules.first.rule_type
		assert_equal 'example.com', sections.first.style_section_rules.first.rule_value
		assert_equal 'a { color: blue; }', sections.first.css
		assert !sections[1].global
		assert_equal 1, sections[1].style_section_rules.size
		assert_equal 'domain', sections[1].style_section_rules.first.rule_type
		assert_equal 'example.net', sections[1].style_section_rules.first.rule_value
		assert_equal 'b { color: red; }', sections[1].css
	end

	test 'multiple rules' do
		sections = Style.parse_moz_docs_for_code("@-moz-document domain(example.com), domain(example.net) {* { color: blue; }}")
		assert_equal 1, sections.size
		assert !sections.first.global
		assert_equal 2, sections.first.style_section_rules.size
		assert_equal 'domain', sections.first.style_section_rules.first.rule_type
		assert_equal 'example.com', sections.first.style_section_rules.first.rule_value
		assert_equal 'domain', sections.first.style_section_rules[1].rule_type
		assert_equal 'example.net', sections.first.style_section_rules[1].rule_value
		assert_equal '* { color: blue; }', sections.first.css
	end

	test 'global' do
		sections = Style.parse_moz_docs_for_code("* { color: blue; }")
		assert_equal 1, sections.size
		assert sections.first.global
		assert sections.first.style_section_rules.empty?
		assert_equal '* { color: blue; }', sections.first.css
	end

	test 'global and non-global' do
		sections = Style.parse_moz_docs_for_code("* { color: blue; }@-moz-document domain(example.net) {b { color: red; }}")
		assert_equal 2, sections.size
		assert sections.first.global
		assert sections.first.style_section_rules.empty?
		assert_equal '* { color: blue; }', sections.first.css
		assert !sections[1].global
		assert_equal 1, sections[1].style_section_rules.size
		assert_equal 'domain', sections[1].style_section_rules.first.rule_type
		assert_equal 'example.net', sections[1].style_section_rules.first.rule_value
		assert_equal 'b { color: red; }', sections[1].css
	end

	test 'retain comments inside moz-doc' do
		sections = Style.parse_moz_docs_for_code("@-moz-document domain(example.com) {/* set everything blue*/ * { color: blue; }}")
		assert_equal 1, sections.size
		assert !sections.first.global
		assert_equal 1, sections.first.style_section_rules.size
		assert_equal 'domain', sections.first.style_section_rules.first.rule_type
		assert_equal 'example.com', sections.first.style_section_rules.first.rule_value
		assert_equal '/* set everything blue*/ * { color: blue; }', sections.first.css
	end

	test 'retain comments outside moz-doc' do
		sections = Style.parse_moz_docs_for_code("/* global part one start */ *{ color: red;} /* global part one end*/@-moz-document domain(example.com) {/* set everything blue*/* { color: blue; }}/* global part two start */ *{ color: yellow;} /* global part two end*/")
		assert_equal 3, sections.size
		assert sections[0].global
		assert !sections[1].global
		assert sections[2].global
		assert_equal '/* global part one start */ *{ color: red;} /* global part one end*/', sections[0].css
		assert_equal '/* global part two start */ *{ color: yellow;} /* global part two end*/', sections[2].css
	end

	test 'drop whitespace-only global sections' do
		sections = Style.parse_moz_docs_for_code("
		@-moz-document domain(example.com) {/* set everything blue*/* { color: blue; }}
		")
		assert_equal 1, sections.size
		assert !sections.first.global
	end

	test 'drop comments-only global sections' do
		sections = Style.parse_moz_docs_for_code("/*before moz doc*/@-moz-document domain(example.com) {/* set everything blue*/* { color: blue; }}/*after moz doc*/")
		assert_equal 1, sections.size
		assert !sections.first.global
	end

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
		sections = Style.parse_moz_docs_for_code("
			@-moz-document domain(google.com) {* { color: blue; }}
		")
		assert_equal 1, sections.length
		assert_equal 1, sections[0].style_section_rules.length
		assert_equal 'domain',  sections[0].style_section_rules[0].rule_type
		assert_equal 'google.com', sections[0].style_section_rules[0].rule_value
		assert_equal '* { color: blue; }', sections[0].css
	end

	test "parse moz doc minimal spaces" do
		sections = Style.parse_moz_docs_for_code("
			@-moz-document domain(google.com){*{color:blue;}}
		")
		assert sections.length == 1, sections.length
		assert sections[0].style_section_rules.length == 1, sections[0].style_section_rules.length
		assert sections[0].style_section_rules[0].rule_type == 'domain'
		assert sections[0].style_section_rules[0].rule_value == 'google.com'
		assert sections[0].css == '*{color:blue;}', sections[0].css
	end

	test "parse moz doc regexp with curly bracket" do
		sections = Style.parse_moz_docs_for_code("
			@-moz-document regexp(\"a{2}\") {* { color: blue; }}
		")
		assert sections.length == 1, sections.length
		assert sections[0].style_section_rules.length == 1, "#{sections[0].style_section_rules.length} from #{sections}"
		assert sections[0].style_section_rules[0].rule_type == 'regexp'
		assert sections[0].style_section_rules[0].rule_value == 'a{2}', sections[0].style_section_rules[0].rule_value
		assert sections[0].css == '* { color: blue; }', sections[0].css
	end

	test "parse moz doc regexp with curly bracket and comma" do
		sections = Style.parse_moz_docs_for_code("
			@-moz-document regexp(\"a{2,3}\") {* { color: blue; }}
		")
		assert sections.length == 1, sections.length
		assert sections[0].style_section_rules.length == 1, sections[0].style_section_rules.length
		assert sections[0].style_section_rules[0].rule_type == 'regexp'
		assert sections[0].style_section_rules[0].rule_value == 'a{2,3}', sections[0].style_section_rules[0].rule_value
		assert sections[0].css == '* { color: blue; }', sections[0].css
	end

private

end
