@styles = Style.find(:all, :conditions => 'obsolete = 0', :include => [:user, :style_code], :order => 'users.name, styles.id')
@styles.each do |style|
	next if style.style_code.nil?
	if !style.style_code.valid?
		urls = style.style_code.errors.full_messages.map do |m|
			m.sub('Code contains an invalid URL reference - ', '').sub('. Only absolute URLs to one of the following protocols is allowed - http:, data:, moz-icon:, chrome:, https:. For user-specified URLs, use style settings.', '').gsub("'", '')
		end
		#urls.each do |url|
		#	puts style.full_pretty_url if url != url.strip and !url.strip.empty?
		#end
		#puts style.user.name + ' - ' + style.full_pretty_url + ' - ' + style.short_description + ' - ' + urls.join(', ')
		puts style.id
	end
end
