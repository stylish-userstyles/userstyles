Style.active.where("short_description not regexp '.*[[:graph:]]+$' or short_description not regexp '^[[:graph:]]+.*'").each do |style|
	style.short_description = style.short_description + ' '
	style.save(:perform_validation => false)
	puts "#{style.id} #{style.errors.full_messages} #{style.short_description}"
	
end

User.where("name not regexp '.*[[:graph:]]+$' or name not regexp '^[[:graph:]]+.*'").each do |user|
	user.name = user.name +  ' '
	user.save(:perform_validation => false)
	puts "#{user.id} #{user.errors.full_messages} #{user.name}"
end
