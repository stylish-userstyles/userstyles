require 'date'
require 'csspool'
require 'public_suffix'

class Style < ActiveRecord::Base

	scope :active, -> { where obsolete: 0 }

	include ActionView::Helpers::JavaScriptHelper
	include ActionView::Helpers::DateHelper

	strip_attributes

	has_many :discussions, -> { readonly.order('DateInserted') }, :class_name => 'ForumDiscussion', :foreign_key => 'StyleID'
	has_one :style_code
	has_many :style_settings, -> { order(:ordinal) }
	belongs_to :user
	has_many :screenshots
	belongs_to :admin_delete_reason, -> { readonly }
	has_many :style_sections, -> { order(:ordinal) }, :dependent => :destroy

	alias_attribute :name, :short_description
	alias_attribute :description, :long_description
	alias_attribute :example_url, :screenshot_url_override

	before_save :truncate_values
	def truncate_values
		['moz_doc_error', 'code_error', 'category', 'subcategory'].each do |column|
			next if self[column].nil?
			length = Style.columns_hash[column].limit
			self[column] = self[column][0..length-1] if self[column].length > length
		end
	end

	validates_presence_of :name
	validates_presence_of :description
	validates_length_of :name, :maximum => 50, :allow_nil => true
	validates_length_of :description, :maximum => 1000, :allow_nil => true
	validates_length_of :additional_info, :maximum => 10000, :allow_nil => true
	validates_associated :style_code, :style_settings, :screenshots
	validates_numericality_of :pledgie_id, :allow_nil => true, :greather_than => 0, :message => 'campaign ID must be a number.'
	validates_format_of :example_url, :with => URI::regexp(%w(http https)), :allow_nil => true, :message=> 'must be a http or https URL.'
	validates_length_of :example_url, :maximum => 500, :allow_nil => true
	validates_inclusion_of :license, :in => %w( publicdomain ccby ccbysa ccbynd ccbync ccbyncsa ccbyncnd arr ), :allow_nil => true

	validates_each :redirect_page do |record, attr, value|
		record.errors.add_to_base "Style has been rerouted to #{record.redirect_page}. Updates not possible." unless record.redirect_page.nil?
	end

	validates_each :example_url do |record, attr, value|
		if value.nil?
			record.errors.add attr, 'must be provided; could not determine what site this affects.' if record.category == 'site' and record.subcategory.nil?
		elsif !Style.validate_url(value, false)
			record.errors.add attr, 'must be a valid URL (with protocol, no wildcards).' 
		elsif !record.url_matches_moz_docs(value)
			record.errors.add attr, 'does not match the sites specified in the code.'
		end
	end

	#doesn't work with the alias
	#validates_uniqueness_of :name, :message => "is already used by another style."

	validates_each :name do |record, attr, value|
		record.errors.add attr, "must not start with special characters." unless value.nil? or value.index(/^[\s!"#'\(\-=\[\]\*\+,\.\/~\|\{\}\_\^\[\]]+/).nil?
		if record.id.nil?
			record.errors.add attr, 'is already used by another style' if Style.exists?(['short_description = ?', value])
		else
			record.errors.add attr, 'is already used by another style' if Style.exists?(['short_description = ? AND id != ?', value, record.id])
		end
	end

	validates_each :screenshot_url_override do |record, attr, value|
		record.errors.add attr, "should be the URL that you want to take screenshots of, not the URL to a screenshot." unless value.nil? or /.*(png|gif|jpg|jpeg)$/i.match(value).nil?
	end

	validates_each :style_code do |record, attr, value|
		# check validity, global, namespaces
		e = record.get_parse_error
		if !e.nil?
			record.errors.add(attr, "has an error - #{e}. If you need help, post your code at http://forum.userstyles.org/discussion/34614/new-css-parservalidator .") unless e.nil?
		else
			record.errors.add(attr, "looks unintentionally global. Please read https://github.com/JasonBarnabe/stylish/wiki/Preventing-global-styles .") if record.calculate_unintentional_global
			namespaces = record.calculate_namespaces
			if !namespaces.nil?
				bad_namespaces = namespaces - ['http://www.w3.org/1999/xhtml', 'http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul', 'http://docbook.org/ns/docbook', 'http://www.w3.org/2000/svg', 'http://www.gribuser.ru/xml/fictionbook/2.0', 'http://vimperator.org/namespaces/liberator']
				if bad_namespaces.length == 1
					record.errors.add(attr, "has an invalid namespace: #{bad_namespaces.first}. Read https://github.com/JasonBarnabe/stylish/wiki/CSS-namespaces for info on namespaces.")
				elsif bad_namespaces.length > 1
					record.errors.add(attr, "has invalid namespaces: #{bad_namespaces.join(', ')}. Read https://github.com/JasonBarnabe/stylish/wiki/CSS-namespaces for info on namespaces.")
				end
			end
			
		end
		
		# check @-moz-documents
		record.calculate_moz_docs.each do |fn, value|
			record.errors.add(attr, "has an invalid @-moz-document value: #{fn} #{value}. Read https://github.com/JasonBarnabe/stylish/wiki/Valid-@-moz-document-rules for more info.") if !self.validate_moz_doc(fn, value)
		end
		
		# URL references
		allowed_reference_prefixes = ['http:', 'data:', 'moz-icon:', 'chrome:', 'https:']
		references = record.calculate_external_references
		references.each do |url|
			# allow certain paths
			allowed = false
			allowed_reference_prefixes.each do |start|
				if url.start_with?(start)
					allowed = true
					break
				end
			end
			if url.empty?
				display_url = '(empty string)'
			else
				# .. - rails fails with an ArgumentError in 118n.rb
				# % - rails does other weird things
				display_url = "'" + url.gsub('..', '').gsub('%', '') + "'"
			end
			message = "contains an invalid URL reference - #{display_url}. Only absolute URLs to one of the following protocols is allowed - " + allowed_reference_prefixes.join(', ') + '. For user-specified URLs, use style settings.'
			record.errors.add(attr, message) unless allowed
		end

		docs = record.get_docs_or_nil
		# @imports
		if docs.nil?
			record.code_possibilities.each do |p, c|
				next if c.nil?
				import_match = /@import\s*(?:url\(\s*)?[\'\"]?\s*([^\'\"]+)[\'\"]?\s*\)?/
				c.scan(import_match).each do |url|
					record.errors.add attr, "cannot contain non-chrome imports (they can cause hangs) - #{url[0]}" if !url[0].start_with?('chrome:')
				end
			end
		else
			docs.each do |doc|
				doc.import_rules.each do |r|
					uri = r.uri.value
					record.errors.add attr, "cannot contain non-chrome imports (they can cause hangs) - #{uri}" if !uri.start_with?('chrome:')
				end
			end
		end
		# -moz-binding
		if docs.nil?
			binding_match = /-moz-binding\s*:\s*url\s*\(\s*[\'\"]?([^\'\"]+)[\'\"]?\s*\)/
			record.code_possibilities.each do |p, c|
				next if c.nil?
				c.scan(binding_match).each do |url|
					record.errors.add attr, "cannot contain non-chrome protocol bindings - #{url[0]}" if !url[0].start_with?('chrome:')
				end
			end
		else
			docs.each do |doc|
				doc.rule_sets.each do |r|
					r.declarations.each do |d|
						if ['binding', '-moz-binding'].include?(d.property)
							uri = d.expressions.first.value
							record.errors.add attr, "cannot contain non-chrome protocol bindings - #{uri}" if uri != 'none' and !uri.start_with?('chrome:')
						end
					end
				end
			end
		end

		lengths = record.code_possibilities.map { |o, c| c.nil? ? 0 : c.length }
		record.errors.add(attr, 'is too short') if lengths.min < 5
		allowed_length = record.allow_long_code? ? 400000 : 100000
		record.errors.add(attr, "is too long. Code is #{lengths.max} bytes - max is #{allowed_length} bytes.") if lengths.max > allowed_length
	end

	# Move child record errors onto main
	validate do |style|
		style.errors.delete(:style_settings)
		style.errors.delete(:style_setting_options)
		style.style_settings.each do |ss|
			ss.errors.each do |attr, msg|
				style.errors.add("Style setting #{attr}", msg) unless attr == :style_setting_options
			end
			ss.style_setting_options.each do |so|
				so.errors.each do |attr, msg|
					style.errors.add("Style setting option #{attr}", msg)
				end
			end
		end
		style.errors.delete(:screenshots)
		style.screenshots.each do |screenshot|
			screenshot.errors.each do |attr, msg|
				style.errors.add("Screenshot", msg)
			end
		end
	end

	# Make errors unique
	validate do |style|
		style.errors.keys.each do |key|
			msgs = style.errors.delete(key)
			msgs.uniq!
			msgs.each do |msg|
				style.errors.add(key, msg)
			end
		end
	end

	# used when validating, because setting on the real property saves immediately
	@_tmp_style_settings = nil
	def tmp_style_settings
		@_tmp_style_settings
	end
	def tmp_style_settings=(tss)
		@_tmp_style_settings = tss
	end
	def real_style_settings
		@_tmp_style_settings.nil? ? style_settings : @_tmp_style_settings
	end

	attr_accessor :rating_avg, :rating_count
	
	def is_css_valid?
		if self.style_code.code.count("{") > 0 and self.style_code.code.count("{") == self.style_code.code.count("}") and self.style_code.code.count(":") > 0
			return true
		end
		return false
	end

	def self.newly_added(category, limit)
		return Rails.cache.fetch "styles/newly_added/#{category}/#{limit}" do
			Style.order("created DESC").limit(limit).where("created > #{1.week.ago.strftime('%Y-%m-%d')} AND obsolete = 0 " + (category.nil? ? "" : " AND category = '#{category}'")).load
		end
	end

	def related
		return nil if id.nil?
		conditions = "id != #{self.id} AND obsolete = 0 AND "
		if !subcategory.nil?
			conditions += "subcategory = '#{Style.connection.quote_string(subcategory)}'"
		else
			conditions += "category = '#{Style.connection.quote_string(category)}'"
		end
		return Style.where(conditions).order("user_id = #{user.id} DESC, popularity_score DESC").limit(3)
	end

	def self.top_styles(limit, choose_from)
		return Rails.cache.fetch "styles/top_styles/#{limit}/#{choose_from}" do
			#grab the top n
			possibilities = Style.where(:obsolete => 0).order("popularity_score DESC").limit(choose_from)
			#randomize
			a = possibilities.dup
			possibilities = possibilities.collect { a.slice!(rand(a.length)) }
			#limit to a certain number per subcategory to avoid facebook craziness
			limit_per_category = (limit / 5.0).ceil
			styles = []
			subcategory_counts = {}
			possibilities.each do |style|
				if style.subcategory.nil?
					styles << style
				elsif subcategory_counts[style.subcategory].nil?
					styles << style
					subcategory_counts[style.subcategory] = 1
				elsif subcategory_counts[style.subcategory] < limit_per_category
					styles << style
					subcategory_counts[style.subcategory] = subcategory_counts[style.subcategory] + 1
				end
				break if styles.size >= limit
			end
			# fill in the rest with whatever
			i = 0
			while styles.size < limit
				styles << possibilities[i] unless styles.include?(possibilities[i])
				i = i + 1
			end
			styles
		end
	end

	def self.subcategories(category)
		self.connection.select_all("SELECT subcategory name, SUM(weekly_install_count) installs FROM styles WHERE #{self.sanitize_sql(:category => category)} AND subcategory IS NOT NULL GROUP BY subcategory ORDER BY installs DESC LIMIT 20")
	end

	$namespace_pattern = /^\s*@namespace\s+((url\()|['"])[^"')]+(\)|['"]);?$/i
	def userjs(options)
		has_global = false
		has_non_includable = false
		includes = []

		if options.empty?
			sections = style_sections
		else
			code = optionned_code(options)
			return nil if code.nil?
			# skip the real parser if this is huge - the real parser leaks memory!
			if code.length > 400000
				sections = StyleCode.new(:code => code).old_parse_moz_docs
			else
				sections = Style.parse_moz_docs_for_code(code)
			end
		end

		# if the only global part is a default namespace, we'll strip that out to keep
		global_sections = sections.select {|section| section[:global] }
		if global_sections.size == 1
			sections.delete(global_sections[0]) unless global_sections[0][:css].match($namespace_pattern).nil?
		end

		sections.each do |section|
			#puts "=====#{section[:global]} #{section[:rules].nil? ? '' : section[:rules].length} #{section[:code]}\n\n"
			if section[:global]
				has_global = true
			else
				section.style_section_rules.each do |ssr|
					js_includes = ssr.to_userjs_includes
					if js_includes.nil?
						has_non_includable = true
					else
						includes.concat(js_includes)
					end
				end
			end
			section[:css].gsub!(/\\/, '\&\&')
			section[:css].gsub!('"', '\"')
		end

		include_str = ""

		if !has_global and !has_non_includable
			includes.each do |i|
				include_str += "\n// @include       " + i
			end
		end
		string = <<-END_OF_STRING
// ==UserScript==
// @name          #{self.short_description}
// @namespace     http://userstyles.org
// @description	  #{self.userjs_long_description}
// @author        #{self.user.name}
// @homepage      http://userstyles.org/styles/#{self.id}#{include_str}
// @run-at        document-start
// ==/UserScript==
(function() {
END_OF_STRING
		if sections.length == 1 and !has_non_includable
			string += "var css = \"#{sections[0][:css].gsub(/(\r\n|[\r\n])/, '\n')}\";\n"
		else
			string += "var css = \"\";\n"
			sections.each do |section|
				if !section[:global]
					string += "if (false"
					section.style_section_rules.each do |rule|
						case rule.rule_type
							when 'domain'
								string += " || (document.domain == \"#{escape_javascript(rule.rule_value)}\" || document.domain.substring(document.domain.indexOf(\".#{escape_javascript(rule.rule_value)}\") + 1) == \"#{escape_javascript(rule.rule_value)}\")"
							when 'url'
								string += " || (location.href.replace(location.hash,'') == \"#{escape_javascript(rule.rule_value)}\")"
							when 'url-prefix'
								string += " || (document.location.href.indexOf(\"#{escape_javascript(rule.rule_value)}\") == 0)"
							when 'regexp'
								# we want to match the full url, so add ^ and $ if not already present
								re = rule.rule_value
								re = '^' + re unless re.start_with?('^')
								re = re + '$' unless re.end_with?('$')
								string += " || (new RegExp(\"#{escape_javascript(re)}\")).test(document.location.href)"
						end
					end
					string += ")\n\t"
				end
				string += "css += \"#{section[:css].gsub(/(\r\n|[\r\n])/, '\n')}\";\n"
			end
		end
		string += <<-END_OF_STRING
if (typeof GM_addStyle != "undefined") {
	GM_addStyle(css);
} else if (typeof PRO_addStyle != "undefined") {
	PRO_addStyle(css);
} else if (typeof addStyle != "undefined") {
	addStyle(css);
} else {
	var node = document.createElement("style");
	node.type = "text/css";
	node.appendChild(document.createTextNode(css));
	var heads = document.getElementsByTagName("head");
	if (heads.length > 0) {
		heads[0].appendChild(node); 
	} else {
		// no head yet, stick it whereever
		document.documentElement.appendChild(node);
	}
}
})();
		END_OF_STRING
		return string
	end

	def proxomitron
		string = <<-END_OF_STRING
[Patterns]
Name = "#{self.short_description}"
Active = TRUE
Multi = TRUE
URL = "$TYPE(htm)#{self.proxomitron_includes}"
Limit = 16
Match = "</head>"
Replace = "$STOP()"
	"<style type="text/css"><!-- #{self.userjs_css} --></style>"
	"</head>"
		END_OF_STRING
		return string
	end

	def userjs_long_description
		text = self.long_description.strip
		#we need a shorter version...
		first_line_break = text.index(/[\r\n]/)
		if first_line_break
			text = text[0, first_line_break]
		end
		#include style and user references
		style_references = text.scan(/style [0-9]+/i)
		style_references.each do |style_reference|
			begin
				style = Style.find(style_reference.scan(/[0-9]+/i)[0].to_i)
				if style != nil
					text.sub!(style_reference, style.short_description)
				end
			rescue ActiveRecord::RecordNotFound => ex
				#meh, keep going
			end
		end
		user_references = text.scan(/user [0-9]+/i)
		user_references.each do |user_reference|
			begin
				user = User.find(user_reference.scan(/[0-9]+/i)[0].to_i)
				if user != nil
					text.sub!(user_reference, user.name)
				end
			rescue ActiveRecord::RecordNotFound => ex
				#meh, keep going
			end
		end
		return text
	end

	def calculate_userjs_available?
		self.category != "app"
	end

	def calculate_ie_css_available?
		return false
	end

	def calculate_opera_css_available?
		return false
	end

	def calculate_chrome_json_available?
		self.category != 'app'
	end

	def ie_css
		return ''
	end

	def opera_css(options)
		return ''
	end

	def chrome_json(passed_options)
		o = {:sections => []}
		global_sections = []
		
		if style_settings.empty?
			sections = style_sections
		else
			code = optionned_code(passed_options)
			return nil if code.nil?
			# skip the real parser if this is huge - the real parser leaks memory!
			if code.length > 400000
				sections = StyleCode.new(:code => code).old_parse_moz_docs
			else
				sections = Style.parse_moz_docs_for_code(code)
			end
		end
		
		sections.each do |section|
			s = {:urls => [], :urlPrefixes => [], :domains => [], :regexps => []}
			s[:code] = section[:css].strip
			#puts "\n\nglobal#{section[:global]}"
			if !section[:global]
				section.style_section_rules.each do |rule|
					case rule.rule_type
						when 'domain'
							s[:domains] << rule.rule_value
						when 'url'
							s[:urls] << rule.rule_value
						when 'url-prefix'
							s[:urlPrefixes] << rule.rule_value
						when 'regexp'
							s[:regexps] << rule.rule_value
					end
				end
				s[:domains].uniq!
				s[:urls].uniq!
				s[:urlPrefixes].uniq!
				s[:regexps].uniq!
			else
				global_sections << s
			end
			o[:sections] << s
		end
		if global_sections.size == 1
			o[:sections].delete(global_sections[0]) unless global_sections[0][:code].match($namespace_pattern).nil?
		end

		o[:url] = "http://#{DOMAIN}/styles/#{id}"
		# styles with options are not updatable
		if style_settings.empty?
			o[:updateUrl] = "http://#{DOMAIN}/styles/chrome/#{id}.json" 
		else
			o[:updateUrl] = nil
		end
		o[:name] = short_description
		return o.to_json
	end

	def obsoleting_style
		return nil if self.obsoleting_style_id.nil?
		begin
			return Style.find(self.obsoleting_style_id)
		rescue ActiveRecord::RecordNotFound
		end
		return nil
	end

	def self.increment_installs(style_id, source, ip)
		Style.connection.execute("INSERT IGNORE INTO daily_install_counts (style_id, ip, source) VALUES (#{Style.connection.quote_string(style_id)}, '#{Style.connection.quote_string(ip)}', '#{Style.connection.quote_string(source)}');")
	end
	
	# returns an array of the namespace urls for this style, empty array if none, or null if parse error
	def calculate_namespaces
		namespaces = []
		docs = get_docs_or_nil
		return nil if docs.nil?
		docs.each do |doc|
			namespaces = namespaces + Style.calculate_namespaces_for_doc(doc)
		end
		return namespaces.uniq
	end
	
	def self.calculate_namespaces_for_doc(doc)
		namespaces = []
		doc.namespaces.each do |ns|
			namespaces << ns.uri.value unless namespaces.include?(ns.uri.value)
		end
		return namespaces
	end

	# returns the url of the default (unprefixed) namespace for this style, or null if none or for parse errors
	def calculate_default_namespace
		return nil if self.style_code.nil?
		docs = get_docs_or_nil
		#logger.debug "calculate namespace 1"
		if docs.nil?
			# old method
			namespace_matches = self.style_code.code.match(/\@namespace\s+url\(\"?\S+\"?\)/)
			if namespace_matches == nil
				return nil
			end
			namespace_dec = namespace_matches[namespace_matches.length - 1]
			index_start = namespace_dec.index("(")
			index_end = namespace_dec.rindex(")")
			return namespace_dec[index_start + 1..index_end - 1].gsub(/\"/, "")
		end
		# just look at the first one
		docs.first.namespaces.each do |ns|
			#logger.debug "calculate namespace 2"
			if ns.prefix.nil? or ns.prefix.value == ''
				#raise ns.uri.value
				return ns.uri.value
			end
		end
		#logger.debug "calculate namespace 3"
		return nil
	end

	def calculate_category
		#xul
		return 'app' if self.calculate_default_namespace == "http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul"
		#logger.debug "calculate category 1"
		moz_doc_rules = calculate_moz_docs
		#logger.debug "calculate category 2"
		if moz_doc_rules.empty?
			return 'app' if self.using_xul_selectors
			return 'global'	
		end
		#logger.debug "calculate category 3"
		# look for special cases of moz_doc_rules
		moz_doc_rules.each do |moz_doc_rule|
			#app-specific protocols
			if moz_doc_rule[0] == "url" or moz_doc_rule[0] == "url-prefix"
				if /^(chrome|about|x-jsd|view\-source)/.match(moz_doc_rule[1]) != nil
					return "app"
				end
			end
			#global styles in the form -moz-document url-prefix("http://")
			if moz_doc_rule[0] == "url-prefix" and /^(http|https|ftp|file|data|chm:file):?\/?\/?\/?$/.match(moz_doc_rule[1]) != nil
				return "global"
			end
			#look for odd regexps: "everything except" styles, styles for certain file extensions
			if moz_doc_rule[0] == 'regexp'
				begin
					re = Regexp.new(moz_doc_rule[1])
					return 'global' if ['', '.txt', '.png', '.rss', '.pdf', 'http://', 'https://'].index{|pattern|re.match(pattern)}
				rescue
					# bad regexp, i guess
				end
			end
		end
		#must be a site style
		return "site"
	end

	$app_url_matches = [[/^chrome\:\/\/browser/, 'browser'], [/^about\:/, 'browser'], [/^chrome\:\/\/mozapps/, 'browser'], [/^chrome\:\/\/global/, 'browser'], [/^chrome\:\/\/stylish/, 'Stylish'], [/^chrome\:\/\/greasemonkey/, 'Greasemonkey'], [/^chrome\:\/\/adblockplus/, 'AdblockPlus'], [/^chrome\:\/\/inspector/, 'DOMInspector'], [/^chrome\:\/\/dta/, 'DownThemAll'], [/^chrome\:\/\/fireftp/, 'FireFTP'], [/^chrome\:\/\/speeddial/, 'SpeedDial'], [/^chrome\:\/\/fastdial/, 'FastDial']]
	$app_text_matches = [[/firefox/i, 'browser'], [/stylish/i, 'Stylish'], [/adblock/i, 'AdblockPlus'], [/thunderbird/i, 'Thunderbird'], [/^tb\s/i, 'Thunderbird']]
	$ip_pattern = /^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}):?[0-9]*$/
	def calculate_subcategory
		case self.category
			when "site"
				return Style.get_subcategory_for_url(self.screenshot_url) unless self.screenshot_url.nil?
				using_regexps = false
				good_domains = []
				# let's try without regexps first
				moz_doc_rules = calculate_moz_docs
				moz_doc_rules.each do |moz_doc_rule|
					next if moz_doc_rule[0] == 'regexp' or moz_doc_rule[1].length == 0
					if moz_doc_rule[0] == 'domain'
						domain = Style.get_subcategory_for_domain(moz_doc_rule[1])
					else
						domain = Style.get_subcategory_for_url(moz_doc_rule[1])
					end
					good_domains << domain unless domain.nil?
				end
				# nothing? then regexps.
				if good_domains.empty?
					moz_doc_rules.each do |moz_doc_rule|
						next if moz_doc_rule[0] != 'regexp' or moz_doc_rule[1].length == 0
						domain = Style.get_subcategory_for_url(moz_doc_rule[1])
						good_domains << domain unless domain.nil?
					end
				end
				
				# prefer things that aren't IP addresses
				non_ip_domains = good_domains.reject { |domain| !$ip_pattern.match(domain).nil? }
				return non_ip_domains[0] if !non_ip_domains.empty?
				return good_domains[0] if !good_domains.empty?
				# if we got here, then let's just use the example url the user provided, even if it doesn't match a moz doc. (our parser doesn't handle regexps well, so this accounts for that)
				return Style.get_subcategory_for_url(self.screenshot_url_override) if using_regexps and !self.screenshot_url_override.nil?
				return nil
			when "app"
				moz_doc_rules = calculate_moz_docs
				moz_doc_rules.each do |moz_doc_rule|
					next if moz_doc_rule[1].length == 0
					$app_url_matches.each do |match|
						return match[1] if match[0].match(moz_doc_rule[1])
					end
				end
				$app_text_matches.each do |text_match|
					return text_match[1] if text_match[0].match(self.short_description)
				end
				return 'browser' if moz_doc_rules.empty?
		end
		return nil
	end

	def self.get_subcategory_for_url(url)
		begin
			return Style.get_subcategory_for_domain(URI.parse(url).host)
		rescue
			return nil
		end
	end

	$dont_strip_tld_sites = ['userstyles.org', 'userscripts.org', 'del.icio.us', 'last.fm']
	def self.get_subcategory_for_domain(domain)
		return domain if !domain.include?('.')
		return domain if !$ip_pattern.match(domain).nil?
		return domain if $dont_strip_tld_sites.include?(domain)
		return domain if !PublicSuffix.valid?(domain)
		pd = PublicSuffix.parse(domain)
		return pd.domain if $dont_strip_tld_sites.include?(pd.domain)
		sld = pd.sld
		return pd.domain if pd.sld.nil?
		# last.fm also operates as lastfm.de and such
		return 'last.fm' if sld == 'lastfm'
		return sld
	end

	def validate_screenshot(screenshot, prefix)
		errors = []
		if prefix.nil?
			name = 'screenshot'
		else
			name = prefix + '_screenshot'
		end
		size = screenshot.size unless screenshot.nil?
		if screenshot.nil? or size == 0
			#if nothing was uploaded, it'll report application/octet-stream which will error later. this message is sufficient for that scenario
			errors << [name, "was not specified"]
			return errors
		end
		content_type = screenshot.content_type.strip
		errors << [name, "has a content type of '#{content_type}', must be PNG, GIF, or JPG"] unless content_type == 'image/png' or content_type == 'image/gif' or content_type == 'image/jpeg'	
		errors << [name, "is too big, must be under 200KB"] if size > 200 * 1024
		return errors
	end

	def save_screenshot(screenshot, type)
		if type == :before
			prefix = "before"
		elsif type == :after
			prefix = "after"
		else
			raise Exception
		end
		is_update = get_screenshot_name_by_type(type) != nil
		#delete the existing one
		if is_update
			begin
				File.delete("#{Rails.root}/public/style_screenshots/#{get_screenshot_name_by_type(type)}")
			rescue Errno::ENOENT
				#no file. meh.
			rescue Errno::EISDIR
				#the name must've been blank, so we're referring to the directory. meh.
			end
			if type == :after
				begin
					File.delete("#{Rails.root}/public/style_screenshot_thumbnails/#{get_screenshot_name_by_type(type)}")
				rescue Errno::ENOENT
					#no file. meh.
				rescue Errno::EISDIR
					#the name must've been blank, so we're referring to the directory. meh.
				end
			end
		end
		filename = "#{self.id}_#{prefix}.#{screenshot.content_type.strip.split('/')[1]}"
		File.open("#{Rails.root}/public/style_screenshots/#{filename}", "wb") { |f| f.write(screenshot.read) }
		if type == :after
			if !system("#{Rails.root}/shellscripts/thumbnail.sh #{Rails.root}/public/style_screenshots/#{filename} #{Rails.root}/public/style_screenshot_thumbnails/#{filename} >> #{Rails.root}/log/thumbnail.log 2>&1")
				logger.error "Failed making thumbnail for #{filename}, exit code is #{$?}"
			end
		end
		set_screenshot_name_by_type(type, filename)
	end

	def save_additional_screenshot(data, description)
		screenshot = Screenshot.new
		screenshot.description = description
		screenshot.style = self
		screenshot.path = 'temp'
		screenshot.save!
		filename = "#{self.id}_additional_#{screenshot.id}.#{data.content_type.strip.split('/')[1]}"
		screenshot.path = filename
		screenshot.save!
		full_path = "#{Rails.root}/public/style_screenshots/#{filename}"
		is_update = File.exists?(full_path)
		File.open(full_path, "wb") { |f| f.write(data.read) }
	end

	def delete_additional_screenshot(screenshot)
		begin
			File.delete("#{Rails.root}/public/style_screenshots/#{screenshot.path}", "w")
		rescue Errno::ENOENT
			#no file. meh.
		end
		screenshot.delete
	end

	def change_additional_screenshot(screenshot, data)
		begin
			File.delete("#{Rails.root}/public/style_screenshots/#{screenshot.path}", "w")
		rescue Errno::ENOENT
			#no file. meh.
		end
		filename = "#{self.id}_additional_#{screenshot.id}.#{data.content_type.strip.split('/')[1]}"
		screenshot.path = filename
		screenshot.save!
		File.open("#{Rails.root}/public/style_screenshots/#{filename}", "wb") { |f| f.write(data.read) }
	end

	# applies the style settings to this style
	def optionned_code(params)
		c = style_code.code.dup
		ss = real_style_settings
		# nest this two levels deep
		2.times do
			ss.each do |setting|
				# missing an option?
				return nil unless params.include?(setting.install_key)
				# actual values
				if !params[setting.install_key][:iskey]
					return nil unless ['color', 'image', 'text'].include?(setting.setting_type)
					# escape backslashes and double quotes
					replacement_value = params[setting.install_key][:value].gsub('\\', '\\\\\\\\').gsub('"', '\\"')
					# we need to escape any backslashes in the *replacement* value, as things like \0 are interpreted as regex groups. we're escaping them to 2 backslashes, which gets doubled to 4 when interpreted by the regex system, then 8 by being a ruby string
					c.gsub!("/*[[#{setting.install_key}]]*/", replacement_value.gsub('\\','\\\\\\\\'))
				else
					selected_options = setting.style_setting_options.select {|v| v.install_key == params[setting.install_key][:value]}
					if !selected_options.empty?
						# ditto above, but not double quotes
						c.gsub!("/*[[#{setting.install_key}]]*/", selected_options.first.value.gsub('\\','\\\\\\\\'))
					end
				end
			end
		end
		return c
	end

	$common_prefix_enders = {'google' => 'com', 'orkut' => 'com', 'youtube' => 'com', 'facebook' => 'com', 'schuelervz' => 'de', 'wikipedia' => 'org'}
	def calculate_screenshot_url
		return screenshot_url_override unless screenshot_url_override.nil? or screenshot_url_override.empty?
		return nil if category == 'app' or category == 'global'

		# use only valid stuff
		moz_doc_rules = calculate_moz_docs
		moz_doc_rules = moz_doc_rules.select{|fn, value| Style.validate_moz_doc(fn, value)}
		
		# prefer domain, the url, then url-prefix
		domains = moz_doc_rules.select{|r| r[0] == 'domain'}
		return 'http://' + domains[0][1] if !domains.empty?

		urls = moz_doc_rules.select{|r| r[0] == 'url'}
		urls = urls.select{|r,u| Style.validate_url(u, true)}
		return urls[0][1] if !urls.empty?

		urlPrefixes = moz_doc_rules.select{|r,u| r == 'url-prefix'}
		# try to fix up the url prefixes to handle stuff like http://www.google
		urlPrefixes = urlPrefixes.map do |r,u|
			prefix_value = u
			$common_prefix_enders.each do |k,v|
				prefix_value = prefix_value + '.' + v if prefix_value.end_with?(k)
				prefix_value = prefix_value + v if prefix_value.end_with?(k + '.')
			end
			prefix_value.gsub(/\.$/, ".com")
		end
		urlPrefixes = urlPrefixes.select{|u| Style.validate_url(u, true)}
		return nil if urlPrefixes.empty?
		return urlPrefixes.first
	end

	def url_snippet
		# take out swears
		r = short_description.downcase.gsub(/motherfucking|motherfucker|fucking|fucker|fucks|fuck|shitty|shits|shit|niggers|nigger|cunts|cunt/, '')
		# multiple non-alphas into one
		r.gsub!(/([^0-9a-z])[^0-9a-z]+/) {|s| $1}
		# leading non-alphas
		r.gsub!(/^[^0-9a-z]+/, '')
		# trailing non-alphas
		r.gsub!(/[^0-9a-z]+$/, '')
		# non-alphas into dashes
		r.gsub!(/[^0-9a-z]/, '-')
		# use "theme" if we don't have something suitable
		r = 'theme' if r == 'edit' or r == ''
		return r
	end

	def full_pretty_url
		return 'http://' + DOMAIN + pretty_url
	end

	def pretty_url
		return "/styles/#{self.id}/#{self.url_snippet}"
	end

	def cdn_buster_param
	 "?r=#{self.updated_at.to_i}"
	end

	def after_screenshot_path
		return auto_after_screenshot_path if self.screenshot_type_preference == 'auto'
		return provided_after_screenshot_path if self.screenshot_type_preference == 'manual'
		return nil
	end

	def auto_after_screenshot_path
		return "http://#{SCREENSHOT_DOMAIN}/auto_style_screenshots/#{self.id}-after.png#{cdn_buster_param}" unless self.auto_screenshot_date.nil? or self.auto_screenshots_same
		return nil
	end

	def provided_after_screenshot_path
		return "http://#{SCREENSHOT_DOMAIN}/style_screenshots/#{self.after_screenshot_name}#{cdn_buster_param}" unless self.after_screenshot_name.nil?
	end

	def after_screenshot_thumbnail_path
		return nil if self.screenshot_type_preference == 'auto' and self.auto_screenshots_same
		return auto_after_screenshot_thumbnail_path if self.screenshot_type_preference == 'auto'
		return provided_after_screenshot_thumbnail_path if self.screenshot_type_preference == 'manual'
		return nil
	end

	def provided_after_screenshot_thumbnail_path
		return "http://#{SCREENSHOT_DOMAIN}/style_screenshot_thumbnails/#{self.after_screenshot_name}#{cdn_buster_param}" unless self.after_screenshot_name.nil?
		return nil
	end

	def auto_after_screenshot_thumbnail_path
		return "http://#{SCREENSHOT_DOMAIN}/auto_style_screenshots/#{self.id}-after-thumbnail.png#{cdn_buster_param}" unless self.auto_screenshot_date.nil?
		return nil
	end

	def write_md5
		filename = "#{MD5_PATH}#{self.id}.md5"
		if !self.redirect_page.nil? or !self.style_settings.empty? or self.style_code.nil?
			# delete the file
			begin
				File.delete(filename)
			rescue Errno::ENOENT
				# oh well
			end
		else
			# make the file
			File.open(filename, 'w') do |f|
				f.print self.style_code.md5
			end
			File.chmod(0666, filename)
		end
	end

	def as_json(options = {})
		{
			:url => full_pretty_url,
			:name => short_description,
			:description => long_description,
			:author => user.name,
			:created => created,
			:created_ago => time_ago_in_words(created),
			:updated => updated,
			:updated_ago => updated.nil? ? nil : time_ago_in_words(updated),
			:category => category,
			:subcategory => subcategory,
			:weekly_installs => weekly_install_count,
			:total_installs => total_install_count,
			:rating => rating_string,
			:screenshot => after_screenshot_thumbnail_path,
			:license => effective_license_url
		}
	end

	def effective_license
		license.nil? ? user.license : license
	end

	def effective_license_url
		l = effective_license
		return nil if l.nil?
		return 'http://creativecommons.org/publicdomain/zero/1.0/' if l == 'publicdomain'
		return 'http://creativecommons.org/licenses/by/3.0/' if l == 'ccby'
		return 'http://creativecommons.org/licenses/by-sa/3.0/' if l == 'ccbysa'
		return 'http://creativecommons.org/licenses/by-nd/3.0/' if l == 'ccbynd'
		return 'http://creativecommons.org/licenses/by-nc/3.0/' if l == 'ccbync'
		return 'http://creativecommons.org/licenses/by-nc-sa/3.0/' if l == 'ccbyncsa'
		return 'http://creativecommons.org/licenses/by-nc-nd/3.0/' if l == 'ccbyncnd'
		return nil
	end

	def rating_string
		return 'none' if rating.nil?
		return 'bad' if rating < 1.5
		return 'ok' if rating < 2.5
		return 'good'
	end

	def recent_discussions
		rd = []
		discussions.each do |d|
			rd << d if d.created > 1.year.ago
		end
		return rd
	end

	# returns a "good enough" array of code possibilities based on options
	# runs though every option, but not every combination of options
	# number of options will be a+b+c...
	def lazy_code_possibilities
		#puts "lazying it up\n"
		setting_possibilities = real_style_settings.map { |setting| setting.possibilities }
		defaults = setting_possibilities.map { |p| p.first }
		option_possibilities = [defaults]
		(0..setting_possibilities.size-1).each do |i|
			# if there's other options than the first, let's try them all out
			if setting_possibilities[i].size > 1
				(1..setting_possibilities[i].size-1).each do |j|
					values = Array.new(defaults)
					values[i] = setting_possibilities[i][j]
					option_possibilities << values
				end
			end
		end

		codes = []
		option_possibilities.each do |p|
			param_has = {}
			(0..real_style_settings.length-1).each do |i|
				param_has[real_style_settings[i].install_key] = p[i]
			end
			codes << [param_has, optionned_code(param_has)]
		end
		return codes.first($possibilities_limit)
	end

	$possibilities_limit = 25
	# returns an array of (options, code) for all possibilities for this style (due to options). 
	def code_possibilities
		return [] if style_code.nil?
		return [[{}, style_code.code]] if real_style_settings.empty?

		#puts "checking options\n"
		setting_possibilities = real_style_settings.map { |setting| setting.possibilities }

		# let's see if this going to be a reasonable number. if it's unreasonable, we'll be lazy
		total_count = 1
		setting_possibilities.each do |p|
			total_count = total_count * p.size
		end
		#puts "#{total_count} combinations\n"
		return lazy_code_possibilities if total_count > $possibilities_limit

		#puts "creating combinations\n"
		option_possibilities = nil
		setting_possibilities.each do |p|
			if option_possibilities.nil?
				option_possibilities = p.map {|v| [v]}
			else
				option_possibilities = option_possibilities.product(p)
			end
		end
		codes = []

		#puts "creating codes\n"
		option_possibilities.each do |p|
			param_has = {}
			p.flatten!
			(0..real_style_settings.length-1).each do |i|
				param_has[real_style_settings[i].install_key] = p[i]
			end
			codes << [param_has, optionned_code(param_has)]
		end
		return codes
	end

	# Returns the first parse error encountered for all code possibilities, or nil if no parse error
	def get_parse_error(exempt_stuff=true)
		code_possibilities.each do |a|
			p = a[0]
			code = a[1]
			err = Style.get_parse_error_for_code(code, exempt_stuff)
			return err unless err.nil?
		end
		return nil
	end
	
	# Returns a parse error for the passed code, or nil if no error
	def self.get_parse_error_for_code(code, exempt_stuff=true)
		#return nil if exempt_stuff and !code.index(/box\-shadow|\-moz\-selection|\-moz\-linear\-gradient|\-moz\-appearance/).nil?
		begin
			Style.get_doc(code)
		rescue Racc::ParseError => e
			return e.message
		rescue Exception => e
			return e.message
		end
		return nil
	end
	
	# returns an array of arrays, -moz-doc function to value
	def calculate_moz_docs
		return [] if style_code.nil?
		#logger.debug "calculate_moz_docs 1"
		docs = get_docs_or_nil
		#logger.debug "calculate_moz_docs 2"
		# fall back on old method if this failed
		return style_code.old_style_rules if docs.nil?
		#logger.debug "calculate_moz_docs 4"
		stuff = []
		docs.each do |doc|
			#logger.debug "calculate_moz_docs 5"
			mds = Style.calculate_moz_docs_for_doc(doc)
			stuff = stuff + mds
		end
		#logger.debug "calculate_moz_docs 6"
		return stuff.uniq
	end

	def self.calculate_moz_docs_for_doc(doc)
		stuff = []
		#logger.debug "calculate_moz_docs_for_doc 1"
		doc.document_queries.each do |dq|
			stuff = stuff + dq.url_functions
		end
		# make sure we map before we uniq, because these are complicated objects
		#logger.debug "calculate_moz_docs_for_doc 2"
		stuff.map! do |fn|
			if fn.is_a?(CSSPool::Terms::URI)
				['url', fn.value] 
			else
				[fn.name, fn.params.first.value]
			end
		end
		#logger.debug "calculate_moz_docs_for_doc 3"
		stuff.uniq!
		#logger.debug "calculate_moz_docs_for_doc 4"
		return stuff
	end
	
	def calculate_unintentional_global
		return false if !style_code.code.index('/* i really want this to be global */').nil?
		docs = get_docs_or_nil
		return false if docs.nil?
		docs.each do |doc|
			return true if Style.calculate_unintentional_global_for_doc(doc)
		end
		return false
	end

	def self.calculate_unintentional_global_for_doc(doc)
		return false if Style.using_xul_selectors_for_doc(doc)
		# something outside a moz-doc
		return false if doc.rule_sets.select {|rs| rs.parent_rule.nil? }.empty?
		# not using the xul namespace
		return false if calculate_namespaces_for_doc(doc).include?('http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul')
		# using an ID or class selector
		return !doc.rule_sets.select{|rs|
			!rs.selectors.select {|s|
				!simple_specific = s.simple_selectors.select{|ss| 
					ss.is_a?(CSSPool::Selectors::Id) or ss.is_a?(CSSPool::Selectors::Class) or !ss.additional_selectors.select{|as|
						as.is_a?(CSSPool::Selectors::Id) or as.is_a?(CSSPool::Selectors::Class)
					}.empty?
				}.empty?
			}.empty?
		}.empty?
	end
	
	def using_xul_selectors
		docs = get_docs_or_nil
		return false if docs.nil?
		docs.each do |doc|
			return true if Style.using_xul_selectors_for_doc(doc)
		end
		return false
	end

	# https://developer.mozilla.org/en-US/docs/XUL/XUL_Reference minus button, caption, label, iframe, menu, script, template
	$xul_elements = ['action','arrowscrollbox','assign','bbox','binding','bindings','box','broadcaster','broadcasterset','browser','checkbox','colorpicker','column','columns','commandset','command','conditions','content','datepicker','deck','description','dialog','dialogheader','dropmarker','editor','grid','grippy','groupbox','hbox','image','key','keyset','listbox','listcell','listcol','listcols','listhead','listheader','listitem','member','menubar','menuitem','menulist','menupopup','menuseparator','notification','notificationbox','observes','overlay','page','panel','param','popupset','preference','preferences','prefpane','prefwindow','progressmeter','query','queryset','radio','radiogroup','resizer','richlistbox','richlistitem','row','rows','rule','scale','scrollbar','scrollbox','scrollcorner','separator','spacer','spinbuttons','splitter','stack','statusbar','statusbarpanel','stringbundle','stringbundleset','tab','tabbrowser','tabbox','tabpanel','tabpanels','tabs','textnode','textbox','timepicker','titlebar','toolbar','toolbarbutton','toolbargrippy','toolbaritem','toolbarpalette','toolbarseparator','toolbarset','toolbarspacer','toolbarspring','toolbox','tooltip','tree','treecell','treechildren','treecol','treecols','treeitem','treerow','treeseparator','triple','vbox','where','window','wizard','wizardpage']
	def self.using_xul_selectors_for_doc(doc)
		return !doc.rule_sets.select{|rs|
			!rs.selectors.select {|s|
				!simple_specific = s.simple_selectors.select{|ss| 
					(ss.is_a?(CSSPool::Selectors::Type) and $xul_elements.include?(ss.name)) or !ss.additional_selectors.select{|as|
						as.is_a?(CSSPool::Selectors::Type) and $xul_elements.include?(as.name)
					}.empty?
				}.empty?
			}.empty?
		}.empty?
	end

	def calculate_warnings
		warnings = []
		warnings <<  {:message => code_error, :type => :parse} unless code_error.nil?
		warnings <<  {:message => 'This style has invalid @-moz-document rules. Please read <a href="https://github.com/JasonBarnabe/stylish/wiki/Valid-@-moz-document-rules">this article on valid @-moz-document rules</a>.', :type => :moz_doc} unless moz_doc_error.nil?
		warnings <<  {:message => 'This style looks unintentionally global. Please read <a href="https://github.com/JasonBarnabe/stylish/wiki/Preventing-global-styles">these tips for preventing global styles</a>.', :type => :unintentional_global} if unintentional_global
		# give them a week to have screenshots
		warnings << {:message => "This style is missing a screenshot. Please read <a href=\"/help/coding#screenshots-doc\">tips for posting screenshots</a>.", :type => :screenshot} if after_screenshot_path.nil? and !(screenshot_type_preference == 'auto' and (updated >= 7.days.ago or auto_screenshots_same))
		warnings << {:message => "This style's automatically generated screenshots don't show any changes caused by this style. Please read <a href=\"/help/coding#screenshots-doc\">tips for posting screenshots</a>.", :type => :screenshot} if auto_screenshots_same and screenshot_type_preference == 'auto' and auto_screenshot_date >= updated.to_date
		return warnings
	end

	def refresh_meta
		if self.style_settings.empty?
			self.style_sections = Style.parse_moz_docs_for_code(style_code.code)
		else
			self.style_sections = []
		end
		self.screenshot_url = self.calculate_screenshot_url
		self.category = self.calculate_category
		self.subcategory = self.calculate_subcategory
		self.userjs_available = self.calculate_userjs_available?
		self.opera_css_available = self.calculate_opera_css_available?
		self.ie_css_available = self.calculate_ie_css_available?
		self.chrome_json_available = self.calculate_chrome_json_available?
		self.code_error = self.get_parse_error
		errory_moz_docs = self.calculate_moz_docs.select{|fn, value| !Style.validate_moz_doc(fn, value)}
		if errory_moz_docs.empty?
			self.moz_doc_error = nil
		else
			self.moz_doc_error = errory_moz_docs.join(' ')
		end
		self.unintentional_global = self.calculate_unintentional_global
	end

	def calculate_external_references
		references = Set.new
		docs = get_docs_or_nil
		if docs.nil?
			code_possibilities.each do |o, c|
				references.merge(Style.old_calculate_external_references_for_code(c))
			end
		else
			docs.each do |d|
				references.merge(Style.calculate_external_references_for_doc(d))
			end
		end
		return references
	end

	def url_matches_moz_docs(url)
		moz_docs = calculate_moz_docs
		# global
		return true if moz_docs.empty?
		moz_docs.each do |fn, value|
			case fn
				when 'url'
					return true if url == value
				when 'url-prefix'
					return true if url.start_with?(value)
				when 'domain'
					domain = Style.get_domain(url)
					return true if !domain.nil? and (domain == value or domain.end_with?('.' + value))
				when 'regexp'
					begin
						re = Regexp.new(value)
					rescue Exception => e
						next
					end
					# we want to match the full url, so add ^ and $ if not already present
					res = re.source
					res = '^' + res unless res.start_with?('^')
					res = res + '$' unless res.end_with?('$')
					re = Regexp.new(res)
					return true if re =~ url
			end
		end
		return false
	end

	# Returns an array of all docs for this style, or nil if any are invalid
	# Cache the docs for the life of the request so we don't have to keep reparsing. If the code or settings 
	# change, then don't return the cached copy.
	@_cached_docs = nil
	@_cached_doc_code_hash = nil
	def get_docs_or_nil
		return nil if style_code.nil?
		return @_cached_docs if (!@_cached_docs.nil? and @_cached_doc_code_hash == style_code.code.hash + real_style_settings.hash)
		docs = []
		cp = code_possibilities
		#logger.debug "#{cp.length} possibilities"
		i = 0
		cp.each do |o, c|
			#logger.debug "doing #{i}"
			doc = Style.get_doc_or_nil(c)
			#logger.debug "done #{i}"
			i = i + 1
			if doc.nil?
				@_cached_docs = nil
				@_cached_doc_code_hash = nil
				return nil
			end
			docs << doc
		end
		@_cached_docs = docs
		@_cached_doc_code_hash = style_code.code.hash + real_style_settings.hash
		#logger.debug "done docs"
		return docs
	end
 
	def self.get_doc_or_nil(code)
		begin
			return Style.get_doc(code)
		rescue Exception => e
			return nil
		end
	end

private

	def self.get_doc(code)
		# workaround for 'unclosed comments hang stuff' bug
		last_start_comment = code.rindex('/*')
		if !last_start_comment.nil?
			last_end_comment = code.rindex('*/')
			raise Racc::ParseError.new("unclosed comment on line #{code[0,last_start_comment].lines.count}") if last_end_comment.nil? or last_end_comment < last_start_comment
		end
		return CSSPool::CSS::Document.parse(code)
	end

	def get_screenshot_name_by_type(type)
		if type == :before
			return self.before_screenshot_name
		end
		return self.after_screenshot_name
	end

	def set_screenshot_name_by_type(type, value)
		if type == :before
			self.before_screenshot_name = value
		else
			self.after_screenshot_name = value
		end		
	end	
	
	# ruby's regexp doesn't understand some protocols, so they are exempt
	$moz_doc_validate_exempt_protocols = /^(about|chrome|javascript|chm|zotero|resource|data|dactyl|view\-source|x\-jsd|jar).*/
	$moz_doc_validate_invalid_url_chars = /[\*\s]/
	
	def self.validate_moz_doc(fn, value)
		case fn
			when 'domain'
				return Style.validate_domain(value, false)
			when 'url'
				return Style.validate_url(value, false)
			when 'url-prefix'
				return true if value.empty?
				return true if !(value =~ $moz_doc_validate_exempt_protocols).nil?
				return false if !(value =~ $moz_doc_validate_invalid_url_chars).nil?
				# it could just be the protocol for url-prefix
				return true if !(value =~ /\A(http|https|file|ftp):?\/*\z/).nil?
				# protocol://thenwhatever is ok, we can't validate it as a url because
				# it could end at a weird spot
				return true if !(value =~ /\A(http|https|file|ftp):\/\/.*/).nil?
				return false
			when 'regexp'
				begin
					re = Regexp.new(value)
				rescue Exception => e
					return false
				end
			else
				return false
		end
		return true
	end
	
	def self.validate_url(url, publicly_accessible_only)
		return true if !(url =~ $moz_doc_validate_exempt_protocols).nil? and !publicly_accessible_only
		return false if !(url =~ $moz_doc_validate_invalid_url_chars).nil?
		protocols = publicly_accessible_only ? %w(http https ftp) : %w(http https file ftp)
		return false if (url =~ URI::regexp(protocols)).nil?
		begin
			url_value = URI.parse(url)
		rescue
			return false
		end
		return false if ['http', 'https', 'ftp'].include?(url_value.scheme) and url_value.host.nil?
		# don't validate domain for file:
		return true if ['file'].include?(url_value.scheme)
		return Style.validate_domain(url_value.host, publicly_accessible_only)
	end

	def self.validate_domain(domain, publicly_accessible_only)
		return false if !(domain =~ $moz_doc_validate_invalid_url_chars).nil?
		# ip address
		return true if !(domain =~ /^[0-9]{1,3}(\.[0-9]{1,3}){3}$/).nil?
		# if it's just a bunch of alphanums, assume it's only a TLD or an internal domain
		return true if !(domain =~ /^[a-z0-9\-]+$/).nil? and !publicly_accessible_only
		# some common fake TLDs
		# tp is real but it redirects to tl
		return true if !(domain =~ /.*\.(box|i2p|ip|local|localhost|gci|tp)$/).nil? and !publicly_accessible_only
		return true if PublicSuffix.valid?(domain)
		# tld only
		return (PublicSuffix.valid?('example.' + domain) or PublicSuffix.valid?('example.com.' + domain)) && !publicly_accessible_only
	end

	def self.calculate_external_references_for_doc(doc)
		urls = Set.new
		doc.rule_sets.each do |rs|
			rs.declarations.each do |d|
				d.expressions.each do |e|
					urls << e.value if e.is_a?(CSSPool::Terms::URI)
				end
			end
		end
		return urls
	end

	# returns a set of references in the code to external resources (things references via url(), minus namespaces and -moz-documents)
	def self.old_calculate_external_references_for_code(code)
		references = Set.new

		return references if code.nil?

		code = code.gsub(/[\r\n]+/, '')

		code = StyleCode.strip_comments(code)

		matches = code.scan(/url\s*\(\s*['"]?[^'")]*['"]?\s*\)/i)
		matches.each do |url_statement|
			# get the actual url, stripping out the url(' and ') parts
			url = url_statement.sub(/^url\s*\(\s*['"]?/i, '')
			url.sub!(/['"]?\s*\)$/i, '')

			# check what came immediately before the url (up to start of file, ;, {, or }).
			start_of_url = code.index(url_statement)
			start_of_statement = code.rindex(/;|\}|\{/, start_of_url)
			start_of_statement = 0 if start_of_statement.nil?
			before_statement = code[start_of_statement..start_of_url]
			next if before_statement.include?('namespace') or before_statement.include?('moz-document')

			# look to see if the a [ or a ] is closer before the url. a [ closer indicates we may be in an attribute selector
			close_bracket = code.rindex(/\]/, start_of_url)
			open_bracket = code.rindex(/\[/, start_of_url)
			next if !open_bracket.nil? and (close_bracket.nil? or open_bracket > close_bracket)

			references << url
		end

		return references
	end

	def self.begins_with?(str, re)
		m = str.match(re)
		return !m.nil?# and m.begin(0) == 0
	end

	def self.get_domain(url)
		begin
			return URI.parse(url).host
		rescue
			return nil
		end
	end

	# Parses the code into an array of StyleSections
	def self.parse_moz_docs_for_code(code)
		begin
			doc = Style.get_doc(code)
		rescue Racc::ParseError => e
			return StyleCode.new(:code => code).old_parse_moz_docs
		rescue Exception => e
			return StyleCode.new(:code => code).old_parse_moz_docs
		end
		sections = []
		last_document_query_end = 0
		ordinal = 0
		doc.document_queries.each do |dq|
			# check for global sections
			if dq.outer_start_pos > last_document_query_end
				sections << StyleSection.new({:global => true, :ordinal => ordinal, :css => code[last_document_query_end..dq.outer_start_pos-1].strip})
				ordinal += 1
			end
			section = StyleSection.new({:global => false, :ordinal => ordinal})
			ordinal += 1
			dq.url_functions.each do |fn|
				if fn.is_a?(CSSPool::Terms::URI)
					section.style_section_rules << StyleSectionRule.new({:rule_type => 'url', :rule_value => fn.value})
				else
					section.style_section_rules << StyleSectionRule.new({:rule_type => fn.name, :rule_value => fn.params.first.value})
				end
			end
			section[:css] = code[dq.inner_start_pos..dq.inner_end_pos-1].strip
			sections << section
			last_document_query_end = dq.outer_end_pos
		end
		if last_document_query_end < code.length
			sections << StyleSection.new({:global => true, :ordinal => ordinal, :css => code[last_document_query_end..code.length-1].strip})
		end
		begin
			return sections.select{|s| Style.is_worthwhile_section(s)}
		rescue Racc::ParseError => e
			return StyleCode.new(:code => code).old_parse_moz_docs
		end
	end
	
	# Determines if the code section is worthwhile to include.
	def self.is_worthwhile_section(section)
		# Anything not global will be kept, even if empty
		return true if !section[:global]
		# Only whitespace - drop it. This can be covered by the next case, but this is a common
		# situation and checking it separately is quicker.
		return false if section[:css].strip.empty?
		# See if it contains anything functional. Since CSSPool considers a document with only
		# whitespace and comments to be invalid (see https://github.com/JasonBarnabe/csspool/issues/4),
		# we will tack on a ruleset and see if the resulting document has anything else.
		doc = Style.get_doc(section[:css] + "\na{}")
		return !(
			doc.rule_sets.length == 1 and
			doc.charsets.empty? and
			doc.import_rules.empty? and
			doc.document_queries.empty? and
			doc.supports_rules.empty? and
			doc.namespaces.empty? and
			doc.keyframes_rules.empty?
		)
	end
end
