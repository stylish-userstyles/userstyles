limit = 1000
offset = 0
includes = []
conditions = 'screenshot_url is not null and obsolete = 0'
order = 'styles.id desc'
styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
until styles.empty?
	styles.each do |style|
		if (style.screenshot_url =~ URI::regexp(%w(http https))).nil?
			puts style.id
			if false
				style.screenshot_url_override = nil
				style.refresh_meta
				style.save(false)
			end
		end
	end
	offset = offset + limit
	styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
end
puts "Done"
