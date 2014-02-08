Style.includes(:style_code, :style_settings => [:style_setting_options]).find_in_batches(batch_size: 100) do |styles_batch|
	styles_batch.each do |style|
		style.md5 = style.calculate_md5
		style.save(:validate => false)
	end
	puts "Completed up to #{styles_batch.last.id}"
end
