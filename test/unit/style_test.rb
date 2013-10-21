require 'test_helper'
 
class StyleTest < ActiveSupport::TestCase
	
	# charsets always have to be first
  test "charset is first on opera css" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
@charset "UTF-8";
			@namespace url(http://www.w3.org/1999/xhtml);
			@-moz-document domain("example.com") { /*rules*/ }
		END_OF_STRING
		opera_code = style.opera_css({}).gsub(/[\t\n]/, '')
		assert opera_code.start_with?('@charset "UTF-8";/*Style name'), opera_code
  end


	# url reference tests
  test "url() references without quotes" do
		code = <<-END_OF_STRING
			* { background-image: url(http://example.com/example.png); }
		END_OF_STRING
		references = StyleCode.get_external_references(code)
		assert references.size == 1
		assert references.first == 'http://example.com/example.png'
  end

  test "url() references with single quotes" do
		code = <<-END_OF_STRING
			* { background-image: url('http://example.com/example.png'); }
		END_OF_STRING
		references = StyleCode.get_external_references(code)
		assert references.size == 1
		assert references.first == 'http://example.com/example.png'
  end

  test "url() references with double quotes" do
		code = <<-END_OF_STRING
			* { background-image: url("http://example.com/example.png"); }
		END_OF_STRING
		references = StyleCode.get_external_references(code)
		assert references.size == 1
		assert references.first == 'http://example.com/example.png'
  end

  test "multiple url() references" do
		code = <<-END_OF_STRING
			* { background-image: url("http://example.com/example1.png"); }
			* { background-image: url("http://example.com/example2.png"); }
		END_OF_STRING
		references = StyleCode.get_external_references(code)
		assert references.size == 2
		a = references.to_a
		assert (a[0] == 'http://example.com/example1.png' or a[0] == 'http://example.com/example2.png')
		assert (a[1] == 'http://example.com/example1.png' or a[1] == 'http://example.com/example2.png')
  end

  test "namespaces not counted as url() references" do
		code = <<-END_OF_STRING
			@namespace url('http://example.com/');
			* { background-image: url("http://example.com/example1.png"); }
		END_OF_STRING
		references = StyleCode.get_external_references(code)
		assert references.size == 1
		assert references.first == 'http://example.com/example1.png'
  end

  test "-moz-document not counted as url() references" do
		code = <<-END_OF_STRING
			@-moz-document url('http://example.com/') {
			* { background-image: url("http://example.com/example1.png"); }
			}
		END_OF_STRING
		references = StyleCode.get_external_references(code)
		assert references.size == 1
		assert references.first == 'http://example.com/example1.png'
  end

  test "attribute selector not counted as url() references" do
		code = <<-END_OF_STRING
			*[style="background-image: url('http://example.com/')"] { background-image: url("http://example.com/example1.png"); }
		END_OF_STRING
		references = StyleCode.get_external_references(code)
		assert references.size == 1
		assert references.first == 'http://example.com/example1.png'
  end

  test "commented code not counted as url() references" do
		code = <<-END_OF_STRING
			a { /*background-image: url("http://example.com/example1.png"); */}
		END_OF_STRING
		references = StyleCode.get_external_references(code)
		assert references.size == 0
  end

  test "http: url() is allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(http://example.com/example.png); }
		END_OF_STRING
		assert style.style_code.valid?
  end

  test "file: url() is not allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(file:///home/jason/example.png); }
		END_OF_STRING
		assert !style.style_code.valid?
  end

  test "resource: url() is not allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(resource://example.png); }
		END_OF_STRING
		assert !style.style_code.valid?
  end

  test "relative url() is not allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(../example.png); }
		END_OF_STRING
		assert !style.style_code.valid?
  end

  test "blank url() is not allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(); }
		END_OF_STRING
		assert !style.style_code.valid?
  end

  test "data: url() is allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==); }
		END_OF_STRING
		assert style.style_code.valid?
  end

  test "data: url() is allowed with whitespace" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA
AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO
9TXL0Y4OHwAAAABJRU5ErkJggg==); }
		END_OF_STRING
		assert style.style_code.valid?
  end

  test "chrome: url() is allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(chrome://example/example.png); }
		END_OF_STRING
		assert style.style_code.valid?
  end

  test "moz-icon: url() is allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(moz-icon://example.png); }
		END_OF_STRING
		assert style.style_code.valid?
  end

  test "https: url() is allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(https://example.com/example.png); }
		END_OF_STRING
		assert style.style_code.valid?
  end

  test "style setting is allowed" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(/*[[setting]]*/); }
		END_OF_STRING
		assert style.style_code.valid?
  end


	# parsing tests
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
		assert sections[0][:rules].length == 1, sections[0][:rules].length
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


	# categorization tests
  test "categorization of file extension regexp" do
    style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@namespace url(http://www.w3.org/1999/xhtml);

			@-moz-document regexp('.*?.jpg'), regexp('.*?.png'), regexp('.*?.gif'), regexp('.*?/2000'){
			html{background-color:rgba(0,0,0, 0.8) !important}
			}
		END_OF_STRING
		style.moz_doc_rules = style.style_code.rules
		assert style.calculate_category == 'global', style.calculate_category
  end


	test "nested settings" do
		style = get_style_template()
		style.style_code.code = '/*[[one]]*/'
		
		so1 = StyleOption.new
		so1.name = 'one'
		so1.id = 1
		
		sv = StyleOptionValue.new
		sv.display_name = 'a'
		sv.value = '* { font-size: /*[[two]]*/ }'
		sv.id = 1
		so1.style_option_values << sv
		
		so2 = StyleOption.new
		so2.name = 'two'
		so2.id = 2
		
		sv = StyleOptionValue.new
		sv.display_name = 'a'
		sv.value = '12px'
		sv.id = 2
		so2.style_option_values << sv
		sv = StyleOptionValue.new
		sv.display_name = 'b'
		sv.value = '13px'
		sv.id = 3
		so2.style_option_values << sv
		
		style.style_options << so1
		style.style_options << so2
		
		assert style.code_possibilities.length == 2, style.code_possibilities
		assert style.code_possibilities[0][1] == '* { font-size: 12px }', style.code_possibilities[0][1]
		assert style.code_possibilities[1][1] == '* { font-size: 13px }', style.code_possibilities[1][1]

		# but what if they're in the wrong order??? (a reference is made before the referenced is defined)
		style.style_options = []
		style.style_options << so2
		style.style_options << so1
		
		assert style.code_possibilities.length == 2, style.code_possibilities
		assert style.code_possibilities[0][1] == '* { font-size: 12px }', style.code_possibilities[0][1]
		assert style.code_possibilities[1][1] == '* { font-size: 13px }', style.code_possibilities[1][1]

	end
	
	def get_style_template
    return Style.new(
			:id => 123,
			:short_description => 'Style name',
			:long_description => 'Style description',
			:user => User.new(:name => 'me'),
			:style_code => StyleCode.new
		)
	end

end
