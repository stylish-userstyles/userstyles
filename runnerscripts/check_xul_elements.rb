require 'csspool'

def h(s)
	s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
end

bad_styles = []
bad_styles_with_mozdocs = []

limit = 200
offset = 0
includes = [:style_code]
conditions = 'obsolete = 0 and code_error is null and category = "global"'
order = 'styles.id'
styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
until styles.empty?
	styles.each do |style|
		if style.using_xul_selectors
			#puts "<!--#{style.id} bad-->"
			bad_styles << style.id
		else
			#puts "<!--#{style.id} good-->"
		end
	end
	offset = offset + limit
	styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
end
puts "<!--Done finding, now outputting-->"

styles = Style.find(:all, :conditions => "styles.id IN (#{bad_styles.join(', ')})", :include => :user, :order => 'users.name, styles.id')
styles.each do |style|
 	puts "#{h(style.user.name)} <a href='#{h(style.full_pretty_url)}'>#{h(style.short_description)}</a><br>"
end
