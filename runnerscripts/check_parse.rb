require 'csspool'

Style.active.where('code_error is null').includes(:style_code, {:style_options => :style_option_values}).find_in_batches(batch_size: 100) do |styles_batch|
	styles_batch.each do |style|
		puts "Checking #{style.id}"
		style.code_possibilities.each do |o, c|
			sections = Style.parse_moz_docs_for_code(c)
			sections.each do |s|
				# empty blocks are considered invalid, so add a rule.
				CSSPool::CSS::Document.parse(s[:code] + "\na{}")
			end
		end
	end
	puts "Completed up to #{styles_batch.last.id}"
end
