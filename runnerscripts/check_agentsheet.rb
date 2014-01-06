require 'csspool'

def doc_has_agent_specific_stuff(doc)
	doc.rule_sets.each do |rs|
		rs.selectors.each do |s|
			s.simple_selectors.each do |ss|
				return true if ss.is_a?(CSSPool::Selectors::Type) and ss.name == 'scrollbar'
				ss.additional_selectors.each do |as|
					return true if as.is_a?(CSSPool::Selectors::Type) and as.name == 'scrollbar'
				end
			end
		end
	end
	return false
end

Style.active.where('code_error is null').includes(:style_code, {:style_options => :style_option_values}).find_in_batches(batch_size: 100) do |styles_batch|
	styles_batch.each do |style|
		#puts "Checking #{style.id}"
		turn_into_agent = false
		style.code_possibilities.each do |o, c|
			break unless /\/\*\s*AGENT_SHEET\s*\*\//.match(c).nil?
			begin
				doc = CSSPool::CSS::Document.parse(c)
			rescue
				break
			end
			if doc_has_agent_specific_stuff(doc)
				turn_into_agent = true
				break
			end
		end
		if turn_into_agent
			puts "AGENT: #{style.id} #{style.category} #{style.short_description}"
			style.style_code.code = "/* AGENT_SHEET */\n" + style.style_code.code
			style.style_code.save
		end
	end
	#puts "Completed up to #{styles_batch.last.id}"
end
