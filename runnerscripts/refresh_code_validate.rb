require 'csspool'

limit = 200
offset = 0
conditions = 'obsolete = 0'
includes = [:style_code]
@styles = Style.find(:all, :conditions => conditions, :include => includes, :order => 'styles.id', :limit => limit, :offset => offset)
until @styles.empty?
	@styles.each do |style| 
		error = style.get_parse_error
		if style.code_error != error
			puts "updating #{style.id}\n"
			style.code_error = error
			style.save(false)
		end
	end
	offset = offset + limit
	@styles = Style.find(:all, :conditions => conditions, :include => includes, :order => 'styles.id', :limit => limit, :offset => offset)
end
