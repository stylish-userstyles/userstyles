require 'test_helper'
 
class StyleBindingValidationTest < ActiveSupport::TestCase

	test 'no bindings' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			a { color: blue;}
		END_OF_STRING
		assert style.valid?
	end

	test 'chrome binding' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			a { -moz-binding: url('chrome://something/chrome.css') }
		END_OF_STRING
		assert style.valid?
	end

	test 'HTTP bindiing' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			a { -moz-binding: url('http://example.com/import.css') }
		END_OF_STRING
		assert !style.valid?
	end

	test 'hidden HTTP binding' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			a { -moz-binding: /**/url('http://example.com/import.css') }
		END_OF_STRING
		assert !style.valid?
	end

	test 'chrome and HTTP import' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			a { -moz-binding: url('chrome://something/chrome.css') }
			a { -moz-binding: url('http://example.com/import.css') }
		END_OF_STRING
		assert !style.valid?
	end

	test 'none' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			a { -moz-binding: none }
		END_OF_STRING
		assert style.valid?
	end
end
