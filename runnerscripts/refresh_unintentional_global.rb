require 'csspool'

limit = 200
offset = 0
conditions = 'obsolete = 0'
includes = [:style_code]
@styles = Style.find(:all, :conditions => conditions, :include => includes, :order => 'styles.id', :limit => limit, :offset => offset)
until @styles.empty?
	@styles.each do |style| 
		ui = style.calculate_unintentional_global
		if style.unintentional_global != ui
			puts "updating #{style.id}\n"
			style.unintentional_global = ui
			style.save(false)
		end
	end
	offset = offset + limit
	@styles = Style.find(:all, :conditions => conditions, :include => includes, :order => 'styles.id', :limit => limit, :offset => offset)
end
