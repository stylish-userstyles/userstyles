styles = Style.find(:all, :include => [:style_code, :moz_doc_rules])#, :conditions => 'id = 291')
styles.each do |style|
	next if !style.redirect_page.nil?
	puts style.id.to_s + ' ' + style.subcategory + ' ' + style.calculate_subcategory if style.subcategory != style.calculate_subcategory
end
