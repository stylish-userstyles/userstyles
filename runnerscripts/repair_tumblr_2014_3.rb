rows = Style.connection.select_rows("select style_id from styles join style_codes on style_id = styles.id where subcategory = 'tumblr' and !obsolete and (code like '%.l-header%' or code like '%.l-content%') order by style_id")

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
	new_code = new_code.gsub(/div\.l\-header\s+\.iconic\s*\>\s*a\s*\{/, "div.l-header .tab.iconic > a {").gsub(/div\.l\-content\s*\{/, "#left_column, #right_column {background-color: transparent !important;}\n\ndiv.l-content.l-content.l-content {")
	if style.style_code.code != new_code
		CSSPool::CSS::Document.parse(new_code) if !starting_code_invalid
		if true
			File.open("public/tumblrfix/#{style.id}.css", 'w') { |file| file.write(new_code) }
			puts "<div><a href=\"#{style.pretty_url}\">#{CGI::escapeHTML(style.name)}</a> <a href=\"#{style.id}.css\">Code</a></div>"
			puts "<div><a href=\"#{style.pretty_url}\">#{CGI::escapeHTML(style.name)}</a> unchanged</div>" if style.style_code.code == new_code
		else
			puts style.id.to_s
			style.style_code.code = new_code
			style.style_code.save
			style.refresh_meta
			style.write_md5
			style.save(:validate => false)
		end
	end
end
