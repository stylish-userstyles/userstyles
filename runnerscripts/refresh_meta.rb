Style.active.includes(:style_code, {:style_options => :style_option_values}).find_in_batches(batch_size: 100) do |styles_batch|
	styles_batch.each do |style|
		puts "Checking #{style.id}"
		style.refresh_meta
		if !style.changed?
			#puts "Unchanged " + style.id.to_s
		elsif !style.save(:validate => false)
			puts "Couldn't save " + style.id.to_s
		else
			puts "Saved " + style.id.to_s
		end
	end
	puts "Completed up to #{styles_batch.last.id}"
end
