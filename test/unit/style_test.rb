require 'test_helper'
 
class StyleTest < ActiveSupport::TestCase

	test 'valid is valid' do
		style = get_valid_style()
		assert style.valid?
	end

	test 'long moz_doc_error' do
		style = get_valid_style()
		style.moz_doc_error = 'X' * 1000
		style.save
		assert style.moz_doc_error == 'X' * 100
	end

end
