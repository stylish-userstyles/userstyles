require 'csspool'

limit = 1000
offset = 0
includes = [:style_code, :user]
conditions = 'code like "%tumblr%" and code regexp "\}[\r\n]+\}[\r\n]+#home" and obsolete = 0'
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
		# moving the closing bracket to the end
		new_code = style.style_code.code.sub(/\}[\r\n]+\}/, '}') + "\n}"
		begin
			CSSPool::CSS::Document.parse(new_code)
			puts "#{style.id} is cool with the moz-doc fix"

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
			puts "#{style.id} is invalid with the moz-doc fix"
		end
	end
	offset = offset + limit
	styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
end
puts "Done"
