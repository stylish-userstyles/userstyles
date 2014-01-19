Style.active.where("short_description not regexp '.*[[:graph:]]+$' or short_description not regexp '^[[:graph:]]+.*'").each do |style|
	puts "#{style.id} #{style.short_description}"
	style.save(:validate => false)
end

User.where("name not regexp '.*[[:graph:]]+$' or name not regexp '^[[:graph:]]+.*'").each do |user|
	puts "#{user.id} #{user.name}"
	user.save(:validate => false)
end
