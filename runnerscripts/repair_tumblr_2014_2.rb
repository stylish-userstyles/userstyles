rows = Style.connection.select_rows("select style_id from styles join style_codes on style_id = styles.id where subcategory = 'tumblr' and !obsolete and (code like '%#content%' or  code like '%#header%')")

data = {}
rows.each do |id, type, value|
	data[id] = [] if data[id].nil?
	data[id] << [type, value]
end
data.each do |id, rules|
	style = Style.includes(:style_code).find(id)
	new_code = style.style_code.code
	starting_code_invalid = false
	begin
		CSSPool::CSS::Document.parse(new_code)
	rescue
		starting_code_invalid = true
	end
	new_code = new_code.gsub(/#content(?![a-zA-Z0-9\-\_])/, "div.l-content\\1").gsub(/#header(?![a-zA-Z0-9\-\_])/, "div.l-header\\1")
	if style.style_code.code != new_code
		File.open("public/tumblrfix/#{style.id}.css", 'w') { |file| file.write(new_code) }
		puts "<div><a href=\"#{style.pretty_url}\">#{CGI::escapeHTML(style.name)}</a> <a href=\"#{style.id}.css\">Code</a></div>"
		puts "<div><a href=\"#{style.pretty_url}\">#{CGI::escapeHTML(style.name)}</a> unchanged</div>" if style.style_code.code == new_code
		CSSPool::CSS::Document.parse(new_code) if !starting_code_invalid
		#puts style.id.to_s
		#style.style_code.code = new_code
		#style.style_code.save
	end
end
