require 'test_helper'
 
class StyleTest < ActiveSupport::TestCase

	test 'valid is valid' do
		style = get_valid_style()
		assert style.valid?
	end

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
	
	test 'long moz_doc_error' do
		style = get_valid_style()
		style.moz_doc_error = 'X' * 1000
		style.save
		assert style.moz_doc_error == 'X' * 100
	end

end
