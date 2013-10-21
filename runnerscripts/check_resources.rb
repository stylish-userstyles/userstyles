#!/usr/bin/env ruby
allowed_weird_starts = ['http:', 'data:', 'moz-icon:', 'chrome:', 'https:']

ARGF.each do |line|
	parts = line.split("\t", 2)
	# scan for url()
	matches = parts[1].scan(/url\s*\(\s*['"]?[^'")]*['"]?\s*\)/i)
	next if matches.nil?
	#puts '------'
	#puts parts[1]
	matches.each do |url_statements|
		url_statements.each do |url_statement|

			# get the actual url, stripping out the url(' and ') parts
			url = url_statement.sub(/^url\s*\(\s*['"]?/i, '')
			url.sub!(/['"]?\s*\)$/i, '')

			# check what came immediately before the url (up to start of file, ;, {, or }).
			start_of_url = parts[1].index(url_statement)
			start_of_statement = parts[1].rindex(/;|\}|\{/, start_of_url)
			start_of_statement = 0 if start_of_statement.nil?
			before_statement = parts[1][start_of_statement..start_of_url]
			next if before_statement.include?('namespace') or before_statement.include?('moz-document')

			# look to see if the a [ or a ] is closer before the url. a [ closer indicates we may be in an attribute selector
			close_bracket = parts[1].rindex(/\]/, start_of_url)
			open_bracket = parts[1].rindex(/\[/, start_of_url)
			next if open_bracket.nil? or (!close_bracket.nil? and open_bracket > close_bracket)

			# ignore settings
			next if url.include?('/*[[')
			
			# allow certain paths
			found_allowed = false
			allowed_weird_starts.each do |start|
				if url.start_with?(start)
					found_allowed = true
					break
				end
			end
			next if found_allowed
			
			#puts '   BEFORE: (' + start_of_statement.to_s + ',' + start_of_url.to_s + ')' + before_statement
			puts parts[0] + "," + url
		end
	end
end

