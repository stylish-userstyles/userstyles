module UsersHelper
	def format_with_separator(number, separator = ',', length = 3 )
		splitter = Regexp.compile "(\\d{#{length}})"
		before, after = number.to_s.split('.')
		before = before.reverse.gsub splitter, '\1' + separator
		str = "#{ before.chomp( separator ).reverse }"
		str += ".#{ after }" if after
		return str
	end

	def user_list(user_counts, description)
		string = "<h2>#{h description}</h2><ol>"
		user_counts.each do |user_count|
			string << "<li>" + link_to((h user_count[0].name), :action => "show", :id => user_count[0].id) + " - " + format_with_separator(user_count[1]) + "</li>"
		end
		string << "</ol>"
		return string
	end

	def obfuscate(text)
		return text.codepoints.map{|c| "&##{c};"}.join('')
	end
end
