styles = Style.find(:all, :conditions => 'obsolete = 0 and email is not null', :include => [:user, :style_code], :order => 'users.name, styles.id')
users = {}
styles.each do |style|
	next if style.style_code.nil?
	if !style.style_code.valid?
		users[style.user.email] = [] if !users.include?(style.user.email)
		users[style.user.email] << style
	end
end
users.each do |email, styles|
	InvalidStyleMailer.deliver_url_format(email, styles)
end
