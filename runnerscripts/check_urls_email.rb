users = {}
File.open("public/badimages.20121127.csv", "r") do |infile|
    while (line = infile.gets)
			info = line.split(',', 3)
			users[info[0]] = {} unless users.has_key?(info[0])
			users[info[0]][info[1]] = [] unless users[info[0]].has_key?(info[1])
			users[info[0]][info[1]] << info[2].rstrip
    end
end

users.each do |user_id, style_ids|
	user = User.find(user_id)
	next if user.email.nil?
	styles = {}
	style_ids.each do |style_id, bad_urls|
		style = Style.find(style_id)
		next if style.obsolete?
		styles[style] = bad_urls
	end
	next if styles.empty?
	puts user.email
	InvalidStyleMailer.deliver_url_unresolved(user.email, styles)
end

