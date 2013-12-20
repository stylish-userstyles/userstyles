require 'public_suffix'

# ruby's regexp doesn't understand some protocols, so they are exempt
exempt_protocols = /^(about|chrome|javascript|chm|zotero|resource|data|dactyl|view\-source|x\-jsd).*/

invalid_url_chars = /[\*\s]/

# Disable support for private TLDs
PublicSuffix::List.private_domains = false

def validate_domain(domain)
	# ip address
	return true if !(domain =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/).nil?
	# if it's just a bunch of alphanums, assume it's only a TLD or an internal domain
	return true if !(domain =~ /^[a-z0-9\-]+$/).nil?
	# some common fake TLDs
	# tp is real but it redirects to tl
	return true if !(domain =~ /.*\.(box|i2p|ip|local|localhost|gci|tp)$/).nil?
	return true if PublicSuffix.valid?(domain)
	# tld only
	return (PublicSuffix.valid?('example.' + domain) or PublicSuffix.valid?('example.com.' + domain))
end

limit = 500
offset = 0
includes = [:style_code]
conditions = 'obsolete = 0'
order = 'styles.id desc'
styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
until styles.empty?
	styles.each do |style|
		moz_docs = style.calculate_moz_docs
		moz_docs.each do |fn, value|
			begin
				case fn
					when 'domain'
						puts "#{style.id} #{fn} #{value} invalid domain" if !validate_domain(value)
					when 'url'
						if !(value =~ exempt_protocols).nil?
						elsif !(value =~ invalid_url_chars).nil?
							puts "#{style.id} #{fn} #{value} invalid url characters" 
						elsif (value =~ URI::regexp(%w(http https file ftp))).nil?
							puts "#{style.id} #{fn} #{value} invalid url" 
						else
							domain = URI.parse(value).host
							puts "#{style.id} #{fn} #{value} invalid domain" if !validate_domain(domain)
						end
					when 'url-prefix'
						if !(value =~ exempt_protocols).nil?
						elsif !(value =~ invalid_url_chars).nil?
							puts "#{style.id} #{fn} #{value} invalid url characters"
						# it could just be the protocol for url-prefix
						elsif !(value =~ /^(http|https|file|ftp):?\/*/).nil?
						elsif (value =~ URI::regexp(%w(http https file ftp))).nil?
							puts "#{style.id} #{fn} #{value} invalid url"
						else
							domain = URI.parse(value).host
							puts "#{style.id} #{fn} #{value} invalid domain" if !validate_domain(domain)
						end
					when 'regexp'
						begin
							re = Regexp.new(value)
						rescue
							# bad regexp
							puts "#{style.id} #{fn} #{value}" 
						end
				end
			rescue Exception => e
				puts "#{style.id} #{fn} #{value} #{e}"
			end
		end
	end
	offset = offset + limit
	styles = Style.find(:all, :conditions => conditions, :include => includes, :order => order, :limit => limit, :offset => offset)
end
puts "Done"
