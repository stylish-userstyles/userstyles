require 'csspool'

def h(s)
	s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
end

limit = 1000
offset = 0
includes = [:style_code]
conditions = 'obsolete = 0 and code_error is null and style_codes.code like "%namespace%"'
order = 'styles.id'
styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
until styles.empty?
	styles.each do |style|
		namespaces = style.calculate_namespaces
		next if namespaces.nil?
		namespaces = namespaces - ['http://www.w3.org/1999/xhtml', 'http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul', 'http://docbook.org/ns/docbook', 'http://www.w3.org/2000/svg', 'http://www.gribuser.ru/xml/fictionbook/2.0', 'http://vimperator.org/namespaces/liberator']
		next if namespaces.empty?
		new_code = style.style_code.code
		namespaces.each do |ns|
			re = Regexp.new "@namespace[^;]+#{Regexp.escape(ns)}[^;]+;\\s*"
			new_code = new_code.gsub(re, '')
		end
		puts "#{style.id}"
		#puts "#{style.id} #{new_code}"
		#puts "===================="
		doc = CSSPool::CSS::Document.parse(new_code)
		if true
			style.style_code.code = new_code
			style.category = style.calculate_category
			style.subcategory = style.calculate_subcategory
			style.userjs_available = style.calculate_userjs_available?
			style.opera_css_available = style.calculate_opera_css_available?
			style.ie_css_available = style.calculate_ie_css_available?
			style.chrome_json_available = style.calculate_chrome_json_available?
			style.screenshot_url = style.calculate_screenshot_url
			style.style_code.save(false)
			style.save(false)
		end
	end
	offset = offset + limit
	styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
end
puts "Done"
