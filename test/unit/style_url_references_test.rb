require 'test_helper'
 
# Tests validation relating to url() references
class StyleUrlReferencesTest < ActiveSupport::TestCase

	test "url() references without quotes" do
		code = <<-END_OF_STRING
			* { background-image: url(http://example.com/example.png); }
		END_OF_STRING
		style = get_style_template
		style.style_code.code = code
		references = style.calculate_external_references
		assert references.size == 1
		assert references.first == 'http://example.com/example.png'
	end

	test "url() references with single quotes" do
		code = <<-END_OF_STRING
			* { background-image: url('http://example.com/example.png'); }
		END_OF_STRING
		style = get_style_template
		style.style_code.code = code
		references = style.calculate_external_references
		assert references.size == 1
		assert references.first == 'http://example.com/example.png'
	end

	test "url() references with double quotes" do
		code = <<-END_OF_STRING
			* { background-image: url("http://example.com/example.png"); }
		END_OF_STRING
		style = get_style_template
		style.style_code.code = code
		references = style.calculate_external_references
		assert references.size == 1
		assert references.first == 'http://example.com/example.png'
	end

	test "multiple url() references" do
		code = <<-END_OF_STRING
			* { background-image: url("http://example.com/example1.png"); }
			* { background-image: url("http://example.com/example2.png"); }
		END_OF_STRING
		style = get_style_template
		style.style_code.code = code
		references = style.calculate_external_references
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
		style = get_style_template
		style.style_code.code = code
		references = style.calculate_external_references
		assert references.size == 1
		assert references.first == 'http://example.com/example1.png'
	end

	test "-moz-document not counted as url() references" do
		code = <<-END_OF_STRING
			@-moz-document url('http://example.com/') {
			* { background-image: url("http://example.com/example1.png"); }
			}
		END_OF_STRING
		style = get_style_template
		style.style_code.code = code
		references = style.calculate_external_references
		assert references.size == 1
		assert references.first == 'http://example.com/example1.png'
	end

	test "attribute selector not counted as url() references" do
		code = <<-END_OF_STRING
			*[style="background-image: url('http://example.com/')"] { background-image: url("http://example.com/example1.png"); }
		END_OF_STRING
		style = get_style_template
		style.style_code.code = code
		references = style.calculate_external_references
		assert references.size == 1
		assert references.first == 'http://example.com/example1.png'
	end

	test "commented code not counted as url() references" do
		code = <<-END_OF_STRING
			a { /*background-image: url("http://example.com/example1.png"); */}
		END_OF_STRING
		style = get_style_template
		style.style_code.code = code
		references = style.calculate_external_references
		assert references.size == 0
	end

	test "http: url() is allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(http://example.com/example.png); }
		END_OF_STRING
		assert style.valid?, style.errors.values
	end

	test "file: url() is not allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(file:///home/jason/example.png); }
		END_OF_STRING
		assert !style.valid?, style.errors.values
	end

	test "resource: url() is not allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(resource://example.png); }
		END_OF_STRING
		assert !style.valid?, style.errors.values
	end

	test "relative url() is not allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(../example.png); }
		END_OF_STRING
		assert !style.valid?, style.errors.values
	end

	test "blank url() is not allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(); }
		END_OF_STRING
		assert !style.valid?, style.errors.values
	end

	test "data: url() is allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg==); }
		END_OF_STRING
		assert style.valid?, style.errors.values
	end

	test "data: url() is allowed with whitespace" do
		style = get_style_template()
		style.style_code.code = "* { background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUA\
AAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO\
9TXL0Y4OHwAAAABJRU5ErkJggg==); }"
		assert style.valid?, style.errors.values
	end

	test "chrome: url() is allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(chrome://example/example.png); }
		END_OF_STRING
		assert style.valid?, style.errors.values
	end

	test "moz-icon: url() is allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(moz-icon://example.png); }
		END_OF_STRING
		assert style.valid?, style.errors.values
	end

	test "https: url() is allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(https://example.com/example.png); }
		END_OF_STRING
		assert style.valid?, style.errors.values
	end

	test "style setting is allowed" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			* { background-image: url(/*[[setting]]*/); }
		END_OF_STRING
		ss = StyleSetting.new
		ss.setting_type = 'image'
		ss.install_key = 'setting'
		ss.label = 'my setting'
		style.style_settings << ss
		assert style.valid?, style.errors.values
	end
	
end
