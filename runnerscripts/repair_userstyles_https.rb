def function_info(f)
	return ['url', f.value] if f.is_a?(CSSPool::Terms::URI)
	return [f.name, f.params.first.value]
end

ids = Style.connection.select_values("select style_id from styles join style_codes on style_id = styles.id where subcategory = 'userstyles.org' and !obsolete")

ids.each do |id|
	style = Style.includes(:style_code).find(id)
	new_code = style.style_code.code.dup
	starting_code_invalid = false
	begin
		doc = CSSPool::CSS::Document.parse(new_code)
	rescue
		starting_code_invalid = true
	end
	next if starting_code_invalid
	# start at the last so that the code indexes don't change as we make changes
	doc.document_queries.reverse.each do |dq|
		# if it has a domain rule, it's cool
		next if dq.url_functions.find{ |uf|
			n, v = function_info(uf)
			next v == 'domain' && ['userstyles.org'].include?(v)
		}
		# find http rules
		http_functions = dq.url_functions.select{ |uf|
			n, v = function_info(uf)
			next ['url', 'url-prefix'].include?(n) && (v.starts_with?('http://userstyles.org') || v.starts_with?('http://forum.userstyles.org'))
		}
		# does it not have the equivalent https rule?
		missing_https_functions = http_functions.select{ |http_uf|
			hun, huv = function_info(http_uf)
			dq.url_functions.find{|uf|
				un, uv = function_info(uf)
				next un == hun && uv == huv.sub(/^http:/, 'https:')
			}.nil?
		}
		next if missing_https_functions.empty?
		#puts "style #{id} is missing #{missing_https_functions.map{|f|function_info(f)}}"
		new_code = new_code.insert(dq.inner_start_pos - 1,
			', ' + 
			missing_https_functions.map{|uf|
				un, uv = function_info(uf)
				next "#{un}(\"#{uv.sub(/^http:/, 'https:')}\")"
			}.join(', ') + ' '
		)
		#puts new_code
	end
	next if new_code == style.style_code.code
	# make sure it remains valid code
	CSSPool::CSS::Document.parse(new_code)

	if false
		File.open("public/userstylesfix/#{style.id}.css", 'w') { |file| file.write(new_code) }
		puts "<div><a href=\"#{style.pretty_url}\">#{CGI::escapeHTML(style.name)}</a> <a href=\"#{style.id}.css\">Code</a></div>"
	else
		puts style.id.to_s
		style.style_code.code = new_code
		style.style_code.save
		style.refresh_meta
		style.write_md5
		style.save(:validate => false)
	end
end
