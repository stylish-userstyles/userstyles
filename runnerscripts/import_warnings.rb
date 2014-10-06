File.open(ARGV[0], "r") do |f|
	f.each_line do |line|
		parts = line.split("\t")
		PrecalculatedWarning.create(:style_id => parts[0], :warning_type => 'image', :detail => "#{parts[2]} (#{parts[1]})".truncate(1000))
	end
end
