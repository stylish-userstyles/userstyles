Style.includes(:style_code).find_in_batches(batch_size: 100) do |styles_batch|
	styles_batch.each do |style|
		style.write_md5
	end
	puts "Completed up to #{styles_batch.last.id}"
end
