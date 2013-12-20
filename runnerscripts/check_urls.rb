$image_types = ['image/gif', 'image/jpeg', 'image/jpg', 'image/png', 'image/x-icon', 'image/svg+xml', 'font/woff', 'image/vnd.microsoft.icon', 'application/x-font-ttf', 'image/bmp', 'application/octet-stream', 'application/vnd.ms-fontobject', 'font/x-woff', 'application/x-woff', 'image/x-ms-bmp', 'jpg', 'gif', 'png', 'image/pjpeg']
$ignore_content_type_extensions = ['.cur', '.ico', '.ttf']
$ignore_content_type_types = ['text/plain']
$known_bad_urls = {}
$known_good_urls = []

def fetch(uri_str, limit = 3)
	raise ArgumentError, 'too many HTTP redirects' if limit == 0

	uri = URI(uri_str.strip.gsub(' ', '%20').gsub('|', '%7C').gsub('[', '%5B').gsub(']', '%5D'))
	req = Net::HTTP::Get.new(uri.to_s)
	
	#req['If-Modified-Since'] = file.mtime.rfc2822

	con = Net::HTTP.new(uri.host, uri.port)
	if uri.scheme == 'https'
		con.verify_mode = OpenSSL::SSL::VERIFY_NONE
		con.use_ssl = true
	end
	res = con.start {|http|
		http.request(req)
	}

	if res.kind_of?(Net::HTTPRedirection)
		# handle relative redirects
		redirect = URI.join(uri.to_s, res['location'])
		return fetch(redirect.to_s, limit - 1) 
	end

	return res
end

def validate(url)
	begin
		res = fetch(url)
	rescue Errno::ETIMEDOUT
		return 'TIMEOUT'
	rescue Timeout::Error
		return 'TIMEOUT2'
	rescue EOFError
		return 'EOFError'
	rescue ArgumentError
		return 'Too many redirects'
	rescue Errno::ECONNREFUSED
		return 'Connection refused'
	rescue Exception => e  
		return 'Unhandled exception - ' + e.message
	end
	return 'HTTP ' + res.code if res.code != '200'
	return 'No Content-Type' if res['Content-Type'].nil?
	type = res['Content-Type'].split(';')[0]
	if !$image_types.include?(type.downcase)
		if $ignore_content_type_types.include?(type)
			$ignore_content_type_extensions.each do |ext|
				return nil if url.end_with?(ext)
			end
		end
	 	return type
	end
	return nil
end


@styles = Style.find(:all, :conditions => 'obsolete = 0', :include => [:user, :style_code], :order => 'users.name, styles.id')#, :limit => 100)
@styles.each do |style|
	next if style.style_code.nil?
	refs = StyleCode.get_external_references(style.style_code.code)
	refs.each do |url|
		next unless url.start_with?('http:') or url.start_with?('https:')
		if $known_bad_urls.include?(url)
			puts style.user.name + ' ' + style.full_pretty_url + ' ' + url + ' ' + $known_bad_urls[url]
			next
		end
		next if $known_good_urls.include?(url)
		error = validate(url)
		if error.nil?
			$known_good_urls << url
		else
			$known_bad_urls[url] = error
			puts style.user.name + ' ' + style.full_pretty_url + ' ' + url + ' ' + error
		end
	end
end

