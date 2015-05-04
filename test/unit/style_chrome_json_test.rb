require 'test_helper'

class StyleChromeJsonTest < ActiveSupport::TestCase

	test 'default namespace combined with one section' do
		style = Style.new(style_code: StyleCode.new(code: "@namespace url(http://www.w3.org/1999/xhtml);\n@-moz-document domain(example.com) {* { color: blue; }}"))
		style.refresh_meta(true)
		json = JSON.parse style.chrome_json({})
		assert_equal 1, json['sections'].size
		assert_equal "@namespace url(http://www.w3.org/1999/xhtml);\n* { color: blue; }", json['sections'].first['code']
	end

	test 'two namespaces combined with one section' do
		style = Style.new(style_code: StyleCode.new(code: "@namespace url(http://www.w3.org/1999/xhtml);\n@namespace svg url(http://www.w3.org/2000/svg);\n@-moz-document domain(example.com) {* { color: blue; }}"))
		style.refresh_meta(true)
		json = JSON.parse style.chrome_json({})
		assert_equal 1, json['sections'].size
		assert_equal "@namespace url(http://www.w3.org/1999/xhtml);\n@namespace svg url(http://www.w3.org/2000/svg);\n* { color: blue; }", json['sections'].first['code']
	end

	test 'default namespace not combined with two sections' do
		style = Style.new(style_code: StyleCode.new(code: "@namespace url(http://www.w3.org/1999/xhtml);\n@-moz-document domain(example.com) {* { color: blue; }}@-moz-document domain(example.org) {* { color: blue; }}"))
		style.refresh_meta(true)
		json = JSON.parse style.chrome_json({})
		assert_equal 3, json['sections'].size
		assert_equal "@namespace url(http://www.w3.org/1999/xhtml);", json['sections'][0]['code']
		assert_equal "* { color: blue; }", json['sections'][1]['code']
		assert_equal "* { color: blue; }", json['sections'][2]['code']
	end
end
