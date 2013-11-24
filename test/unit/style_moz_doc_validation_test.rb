require 'test_helper'
 
class StyleMozDocValidationTest < ActiveSupport::TestCase

	test 'HTTP URL OK' do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("http://example.com/") { * { color: blue; } }
		END_OF_STRING
		assert style.valid?
	end

	test 'HTTP URL bad' do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("this is not a URL") { * { color: blue; } }
		END_OF_STRING
		assert !style.valid?
	end

	test 'HTTP URL missing slash' do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("http:/example.com/") { * { color: blue; } }
		END_OF_STRING
		assert !style.valid?
	end
end
