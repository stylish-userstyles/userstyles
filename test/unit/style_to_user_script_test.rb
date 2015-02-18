require 'test_helper'
 
class StyleToUserScriptTest < ActiveSupport::TestCase

	test 'basic' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
			* { color: blue; }
		END_OF_STRING
		style.refresh_meta

		assert style.userjs.include?('var css = "* { color: blue; }"'), style.userjs
	end

	test 'multiline' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
* {
	color: blue;
}
		END_OF_STRING
		expected_js = <<-END_OF_STRING
var css = [
	"* {",
	"	color: blue;",
	"}"
].join("\\n");
		END_OF_STRING
		style.refresh_meta
		assert style.userjs.include?(expected_js), style.userjs
	end

	test 'multi moz-docs' do
		style = get_valid_style()
		style.style_code.code = <<-END_OF_STRING
@-moz-document domain(example.com) {
* {
	color: blue;
}
}
@-moz-document domain(example2.com) {
* {
	color: red;
}
}
		END_OF_STRING
		expected_js_1 = <<-END_OF_STRING
	css += [
		"* {",
		"	color: blue;",
		"}"
	].join("\\n");
		END_OF_STRING
		expected_js_2 = <<-END_OF_STRING
	css += [
		"* {",
		"	color: red;",
		"}"
	].join("\\n");
		END_OF_STRING

		style.refresh_meta
		assert style.userjs.include?(expected_js_2), style.userjs
	end

end
