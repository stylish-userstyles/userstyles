#grep -v TIMEOUT ~/Desktop/checkurls.txt | grep -v "getaddrinfo" | grep -v "http://example.com/image.gif" | grep -v "Network is unreachable" | cut -f3 | sort -u | awk '{print "<img src=\"" $1 "\">"}' > ~/Desktop/checkurls.html

$ok_types = ['image/gif', 'image/jpeg', 'image/jpg', 'image/png', 'image/x-icon', 'image/svg+xml', 'font/woff', 'image/vnd.microsoft.icon', 'application/x-font-ttf', 'image/bmp', 'application/octet-stream', 'application/vnd.ms-fontobject', 'font/x-woff', 'application/x-woff', 'application/x-font-woff', 'image/x-ms-bmp', 'jpg', 'gif', 'png', 'image/pjpeg', 'image/webp', 'application/font-woff', 'font/otf', 'font/truetype', 'font/ttf', 'image/x-ico', 'image/x-png', 'text/xml']
$ignore_content_type_extensions = ['.cur', '.ico', '.ttf']
$ignore_content_type_types = ['text/plain']
$known_bad_urls = {}
$known_good_urls = []

def fetch(uri_str, limit = 3, head = false)
	limit = 3 if limit.nil?
	raise ArgumentError, 'too many HTTP redirects' if limit == 0

	uri = URI(uri_str.strip.gsub(' ', '%20').gsub('|', '%7C').gsub('[', '%5B').gsub(']', '%5D'))
	if head
		req = Net::HTTP::Head.new(uri.request_uri)
	else
		req = Net::HTTP::Get.new(uri.request_uri)
	end

	req['User-Agent'] = 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:29.0) Gecko/20100101 Firefox/29.0'

	Timeout::timeout(20) {
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
	}
end

def print_error(style_id, image_uri, err)
	puts "#{style_id}\t#{err}\t#{image_uri}"
end

def validate(url)
	begin
		# Start with a HEAD
		vr = validate_response(url, fetch(url, nil, true))
		# If the response isn't good, do a GET
		vr = validate_response(url, fetch(url, nil, false)) if !vr.nil?
		return vr
	# Won't retry on any network error
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
end

def validate_response(url, res)
	return 'HTTP ' + res.code if res.code != '200'
	return 'No Content-Type' if res['Content-Type'].nil?
	type = res['Content-Type'].split(';')[0]
	return 'No Content-Type' if type.nil?
	if !$ok_types.include?(type.downcase)
		if $ignore_content_type_types.include?(type)
			$ignore_content_type_extensions.each do |ext|
				return nil if url.end_with?(ext)
			end
		end
		return type
	end
	return nil
end

def validate_urls(style_refs, mod_this, mod_total)
	style_refs.each do |style_id, refs|
		next unless style_id % mod_total == mod_this
		refs.each do |url|
			next unless url.start_with?('http:') or url.start_with?('https:')
			if $known_bad_urls.include?(url)
				print_error(style_id, url, $known_bad_urls[url])
				next
			end
			next if $known_good_urls.include?(url)
			error = validate(url)
			if error.nil?
				$known_good_urls << url
			else
				$known_bad_urls[url] = error
				print_error(style_id, url, error)
			end
		end
	end
end

#puts "calculating refs"
style_refs = {}
Style.active.includes([:style_code, {:style_settings => :style_setting_options}]).order('styles.id').find_each do |style|
	next if style.style_code.nil?
	refs = style.calculate_external_references
	# used by style options as a placeholder for user-supplied values
	refs.delete('http://example.com/image.gif')
	style_refs[style.id] = refs
end
#puts "done calculating refs"

thread_count = 5
threads = []
(0..(thread_count - 1)).each do |i|
	threads << Thread.new {
		validate_urls(style_refs, i, thread_count)
	}
end

threads.each {|t| t.join}
