step = 500
start = 0
styles = Style.find(:all, :include => [:style_code], :conditions => "id BETWEEN #{start + 1} AND #{start + step}")
while !styles.empty?
	styles.each do |style|
		style.write_md5
	end
	puts "Completed #{start + 1} through #{start + step}"
	start = start + step
	styles = Style.find(:all, :include => [:style_code], :conditions => "id BETWEEN #{start + 1} AND #{start + step}")
end
