require 'test_helper'
 
class StyleSettingTest < ActiveSupport::TestCase

	test "nested settings" do
		style = get_style_template()
		style.style_code.code = '/*[[one]]*/'
		
		ss1 = StyleSetting.new
		ss1.install_key = 'one'
		ss1.label = 'one'
		ss1.setting_type = 'dropdown'
		ss1.id = 1
		
		so = StyleSettingOption.new
		so.label = 'a'
		so.install_key = 'a'
		so.value = '* { font-size: /*[[two]]*/ }'
		so.id = 1
		ss1.style_setting_options << so
		
		ss2 = StyleSetting.new
		ss2.install_key = 'two'
		ss2.label = 'two'
		ss2.setting_type = 'dropdown'
		ss2.id = 2
		
		so = StyleSettingOption.new
		so.label = 'a'
		so.install_key = 'a'
		so.value = '12px'
		so.id = 2
		ss2.style_setting_options << so
		so = StyleSettingOption.new
		so.label = 'b'
		so.install_key = 'b'
		so.value = '13px'
		so.id = 3
		ss2.style_setting_options << so
		
		style.style_settings << ss1
		style.style_settings << ss2
		
		assert style.code_possibilities.length == 2, style.code_possibilities
		assert style.code_possibilities[0][1] == '* { font-size: 12px }', style.code_possibilities[0][1]
		assert style.code_possibilities[1][1] == '* { font-size: 13px }', style.code_possibilities[1][1]

		# but what if they're in the wrong order??? (a reference is made before the referenced is defined)
		style.style_settings = []
		style.style_settings << ss2
		style.style_settings << ss1
		
		assert style.code_possibilities.length == 2, style.code_possibilities
		assert style.code_possibilities[0][1] == '* { font-size: 12px }', style.code_possibilities[0][1]
		assert style.code_possibilities[1][1] == '* { font-size: 13px }', style.code_possibilities[1][1]

	end

	test "rgb" do
		style = get_style_template()
		style.style_code.code = 'a { color: /*[[one]]*/;} a { color: rgb(/*[[one-rgb]]*/);}'

		ss1 = StyleSetting.new
		ss1.install_key = 'one'
		ss1.label = 'one'
		ss1.setting_type = 'color'
		ss1.id = 1

		so = StyleSettingOption.new
		so.label = 'red'
		so.install_key = 'red'
		so.value = '#FF0000'
		so.id = 1
		ss1.style_setting_options << so

		style.style_settings = [ss1]

		code = style.optionned_code({ss1.install_key => {value: '#FFFFFF'}})
		assert_equal 'a { color: #FFFFFF;} a { color: rgb(255, 255, 255);}', code
	end
end
