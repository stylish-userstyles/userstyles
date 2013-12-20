require 'csspool'

def h(s)
	s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;')
end

def csspool_moz_doc_function_to_array(fn)
	return ['url', fn.value] if fn.is_a?(CSSPool::Terms::URI)
	return [fn.name, fn.params.first.value]
end

def activerecord_moz_doc_function_to_array(r)
	return [r.rule_type, r.value]
end

limit = 200
offset = 0
conditions = "obsolete = 0 and styles.id >= 53952"
includes = [:style_code]
@styles = Style.find(:all, :conditions => conditions, :include => includes, :order => 'styles.id', :limit => limit, :offset => offset)
until @styles.empty?
	@styles.each do |style|
		#puts "<!--checking #{style.id}-->\n"
		next if style.style_code.nil?
		csspool_array = style.get_new_moz_docs
		next if csspool_array.nil?
		if csspool_array.index{|a, b| !b.index('/*').nil?}
			puts "#{style.id} has a comment-like string"
			next
		end
		#activerecord_array = style.moz_doc_rules.map do |md|
		activerecord_array = style.style_code.rules.map do |md|
			activerecord_moz_doc_function_to_array(md)
		end
		activerecord_array.uniq!
		activerecord_array.sort!
		if (csspool_array <=> activerecord_array) == 0
			#puts "#{style.id} matches"
		elsif activerecord_array.empty?
			puts "#{style.id} has none on activerecord side"
		else
			puts "#{style.id} doesn't match - #{csspool_array.inspect} - #{activerecord_array.inspect}"
			#exit
		end
		#puts "#{style.id} - #{mds.map{|md|thing=function_to_thing(md);thing[0] + ' => ' + thing[1]}.join(', ')}" unless mds.nil?
	end
	#puts 'loading next set'
	offset = offset + limit
	@styles = Style.find(:all, :conditions => conditions, :include => includes, :order => 'styles.id', :limit => limit, :offset => offset)
end
