replacements = {
	"http://assets.tumblr.com/images/logo.png?alpha&5" => "https://secure.assets.tumblr.com/images/logo/logo.png",
	"http://assets.tumblr.com/images/logo.png?alpha&6" => "https://secure.assets.tumblr.com/images/logo/logo.png",
	"http://assets.tumblr.com/images/logo.png" => "https://secure.assets.tumblr.com/images/logo/logo.png",
	"http://assets.tumblr.com/images/post_icons.png" => "https://secure.assets.tumblr.com/images/post_icons_sprite.png",
	"http://assets.tumblr.com/images/dashboard_controls/icons_sprite.png?4" => "https://secure.assets.tumblr.com/images/dashboard_controls/dashboard_controls_sprite.png"
}

ids = Style.connection.select_values("select style_id from styles join style_codes on style_id = styles.id where  !obsolete and (#{replacements.keys.map{|k| "code like '%#{k}%'"}.join(' OR ')})")

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
	replacements.each do |k, v|
		new_code.gsub!(k, v)
	end

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
