require 'test_helper'
 
class StyleMozDocValidationTest < ActiveSupport::TestCase

	test 'HTTP URL OK' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("http://example.com/") { * { color: blue; } }
		END_OF_STRING
		assert style.valid?
	end

	test 'HTTP URL bad' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("this is not a URL") { * { color: blue; } }
		END_OF_STRING
		assert !style.valid?
	end

	test 'HTTP URL missing slash' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("http:/example.com/") { * { color: blue; } }
		END_OF_STRING
		assert !style.valid?
	end

	test 'HTTP URL prefix stops at period' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("http://example.") { * { color: blue; } }
		END_OF_STRING
		assert style.valid?
	end

	test 'moz-docs match example' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("https://www.facebook.com"), url-prefix("http://www.facebook.com") {
			html {
				min-height:100%;
			}
			}
		END_OF_STRING
		style.example_url = 'http://www.facebook.com/foo'
		style.refresh_meta
		assert style.valid?
	end

	test 'moz-docs don\'t match example' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document url-prefix("https://www.facebook.com"), url-prefix("http://www.facebook.com") {
			html {
				min-height:100%;
			}
			}
		END_OF_STRING
		style.example_url = 'http://userstyles.org/users/233982'
		style.refresh_meta
		assert !style.valid?
	end

end
