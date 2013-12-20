require 'test_helper'
 
class StyleTest < ActiveSupport::TestCase

	test "categorization of file extension regexp" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@namespace url(http://www.w3.org/1999/xhtml);

			@-moz-document regexp('.*?.jpg'), regexp('.*?.png'), regexp('.*?.gif'), regexp('.*?/2000'){
			html{background-color:rgba(0,0,0, 0.8) !important}
			}
		END_OF_STRING
		assert style.calculate_category == 'global', style.calculate_category
	end

	test "categorization of domain with dash" do
		style = get_style_template()
		style.style_code.code = <<-END_OF_STRING
			@-moz-document domain(bg-time.jp) {
			html{background-color:rgba(0,0,0, 0.8) !important}
			}
		END_OF_STRING
		style.refresh_meta
		assert style.subcategory == 'bg-time', style.subcategory
	end


end
