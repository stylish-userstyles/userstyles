rows = Style.connection.select_rows("select style_id, rule_type, rule_value from style_sections join styles on style_id = styles.id join style_section_rules on style_sections.id = style_section_id where style_section_id in (select style_section_id from style_section_rules where rule_type = 'url-prefix' and rule_value like 'http://www.tumblr%') and !obsolete group by style_sections.id having count(style_section_rules.id) = 1")

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
	rules.each do |type, value|
		new_code = new_code.sub(Regexp.new("(@\\-moz\\-document\\s+#{Regexp.escape(type)}\\s*\\(\\s*[\"']?#{Regexp.escape(value)}[\"']?\\s*\\))((?:\\s+|/\\*[^\\*]*?\\*/)*)\\{"), "\\1, #{type}('#{value.sub(/^http:/, "https:")}') \\2 {")
	end
	#File.open("tumblrfix/#{style.id}.css", 'w') { |file| file.write(new_code) }
	#puts "<div><a href=\"#{style.pretty_url}\">#{CGI::escapeHTML(style.name)}</a> <a href=\"#{style.id}.css\">Code</a></div>"
	#puts "<div><a href=\"#{style.pretty_url}\">#{CGI::escapeHTML(style.name)}</a> unchanged</div>" if style.style_code.code == new_code
	#CSSPool::CSS::Document.parse(new_code) if !starting_code_invalid
	puts style.id.to_s
	style.style_code.code = new_code
	style.style_code.save
end
