# Replace o.imm.io images with "none"

ids = Style.connection.select_values("select style_id from styles join style_codes on style_id = styles.id where code like '%http://o.imm.io%' and !obsolete")

ids.each do |id|
	style = Style.includes(:style_code).find(id)
	new_code = style.style_code.code.dup
	starting_code_invalid = false
	begin
		doc = CSSPool::CSS::Document.parse(new_code)
	rescue
		starting_code_invalid = true
	end
	next if starting_code_invalid
	new_code.gsub!(/url\(\s*['\"]?http:\/\/o\.imm\.io\/[^\.]+\.png['"]?\s*\)/, 'none')

	if new_code == style.style_code.code
		puts "#{id} didn't change"
		next
	end

	# make sure it remains valid code
	CSSPool::CSS::Document.parse(new_code)

	if false
		#File.open("public/tumblrfix/#{style.id}.css", 'w') { |file| file.write(new_code) }
		#puts "<div><a href=\"#{style.pretty_url}\">#{CGI::escapeHTML(style.name)}</a> <a href=\"#{style.id}.css\">Code</a></div>"
		puts "#{id} changed"
	else
		puts style.id.to_s
		style.style_code.code = new_code
		style.style_code.save
		style.refresh_meta
		style.write_md5
		style.save(:validate => false)
	end
end
