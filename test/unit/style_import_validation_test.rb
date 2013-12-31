require 'test_helper'
 
class StyleImportValidationTest < ActiveSupport::TestCase

	test 'no imports' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			a { color: blue;}
		END_OF_STRING
		assert style.valid?
	end

	test 'chrome import' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@import url('chrome://something/chrome.css');
		END_OF_STRING
		assert style.valid?
	end

	test 'HTTP import' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@import url('http://example.com/import.css');
		END_OF_STRING
		assert !style.valid?
	end

	test 'hidden HTTP import' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@import /* */url('http://example.com/import.css');
		END_OF_STRING
		assert !style.valid?
	end

	test 'chrome and HTTP import' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			@import url('chrome://something/chrome.css');
			@import url('http://example.com/import.css');
		END_OF_STRING
		assert !style.valid?
	end

end
