limit = 200
offset = 0
conditions = 'obsolete = 0'
styles = Style.find(:all, :conditions => conditions, :include => [:style_code], :order => 'styles.id', :limit => limit, :offset => offset)
until styles.empty?
	styles.each do |style|
		style.refresh_meta
		if !style.changed?
			#puts "Unchanged " + style.id.to_s
		elsif !style.save(false)
			puts "Couldn't save " + style.id.to_s
		else
			puts "Saved " + style.id.to_s
		end
	end
	offset = offset + limit
	puts "Loading offset #{offset}"
	styles = Style.find(:all, :conditions => conditions, :include => [:style_code], :order => 'styles.id', :limit => limit, :offset => offset)
end
puts "Done"
