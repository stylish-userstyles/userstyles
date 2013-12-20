require 'csspool'

limit = 1000
offset = 0
includes = [:style_code, :user]
conditions = "obsolete = 0 and code_error is null and code like '%.dashboard_options_form%' and code not like '%moz-document%'"
order = 'users.name, styles.id'
styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
until styles.empty?
	styles.each do |style|
		next if style.style_code.nil?
		begin
			doc = CSSPool::CSS::Document.parse(style.style_code.code)
		rescue Exception => e
			puts "#{style.id} is not valid to begin with"
			next
		end
		# add a moz-doc, see if it's still valid
		pre = "@-moz-document domain(tumblr.com) {\n"
		post = "\n}"
		begin
			if style.style_code.code.index('@namespace').nil?
				new_code = pre + style.style_code.code + post
			else
				new_code = style.style_code.code[0..style.style_code.code.index(';')] + "\n" + pre + style.style_code.code[style.style_code.code.index(';')+1..-1] + post
			end
			CSSPool::CSS::Document.parse(new_code)
			puts "#{style.id} is cool with the moz-doc"

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
		rescue ParseError => e
			puts "#{style.id} is invalid with the moz-doc"
		end
	end
	offset = offset + limit
	styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
end
puts "Done"
