require 'csspool'

def h(s)
	s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
end

limit = 200
offset = 0
#conditions = 'obsolete = 0 and styles.id NOT IN (82342,76770)'
conditions = "obsolete = 0 and (code like '%box-shadow%' or code like '%-moz-selection%' or code like '%-moz-linear-gradient%' or code like '%-moz-appearance%')"
includes = [:user, :style_code]
@styles = Style.find(:all, :conditions => conditions, :include => includes, :order => 'users.name, styles.id', :limit => limit, :offset => offset)
until @styles.empty?
	@styles.each do |style| 
		#puts "<!--checking #{style.id}-->\n"
		puts "checking #{style.id}"
		error = style.get_parse_error(true)
		#puts "<a href=\"http://userstyles.local/styles/#{style.id}.css\">#{h(error.strip)}</a><br>\n" unless error.nil?
		style.code_error = style.get_parse_error
		if !style.save(false)
			puts "Couldn't save " + style.id.to_s
			next
		end
	end
	#puts 'loading next set'
	offset = offset + limit
	@styles = Style.find(:all, :conditions => conditions, :include => includes, :order => 'users.name, styles.id', :limit => limit, :offset => offset)
end
