require 'date'
require 'csspool'
require 'public_suffix'

class Style < ActiveRecord::Base

	PublicSuffix::List.private_domains = false

	include ActionView::Helpers::JavaScriptHelper
	include ActionView::Helpers::DateHelper

	strip_attributes!

	has_many :discussions, :class_name => 'ForumDiscussion', :finder_sql => 'SELECT gd.*, u.id user_id, u.name user_name FROM GDN_Discussion gd INNER JOIN GDN_UserAuthentication gu ON gu.UserId = gd.InsertUserID INNER JOIN users u ON u.id = gu.ForeignUserKey WHERE gd.StyleID = #{id} AND gd.Closed = 0 ORDER BY gd.DateInserted'
	has_one :style_code
	has_many :style_options, :order => 'ordinal'
	belongs_to :user
	has_many :screenshots
	belongs_to :admin_delete_reason

	alias_attribute :name, :short_description
	alias_attribute :description, :long_description
	alias_attribute :example_url, :screenshot_url_override

	validates_presence_of :name
	validates_presence_of :description
	validates_length_of :name, :maximum => 50, :allow_nil => true
	validates_length_of :description, :maximum => 1000, :allow_nil => true
	validates_length_of :additional_info, :maximum => 10000, :allow_nil => true
	validates_associated :style_code, :style_options, :screenshots
	validates_numericality_of :pledgie_id, :allow_nil => true, :greather_than => 0, :message => 'campaign ID must be a number.'
	validates_format_of :example_url, :with => URI::regexp(%w(http https)), :allow_nil => true, :message=> 'must be a http or https URL.'
	validates_length_of :example_url, :maximum => 500, :allow_nil => true
	validates_inclusion_of :license, :in => %w( publicdomain ccby ccbysa ccbynd ccbync ccbyncsa ccbyncnd arr ), :allow_nil => true

	validates_each :redirect_page do |record, attr, value|
		record.errors.add_to_base "Style has been rerouted to #{record.redirect_page}. Updates not possible." unless record.redirect_page.nil?
	end

	validates_each :example_url do |record, attr, value|
		if record.category == 'site' and record.subcategory.nil?
			record.errors.add attr, 'must be provided; could not determine what site this affects.' if value.nil?
			record.errors.add attr, 'does not match the sites specified in the code.' if !value.nil?
		end
		record.errors.add attr, 'must be a valid URL (with protocol, no wildcards).' if !value.nil? and !Style.validate_url(value, false)
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
		if true
			e = record.get_parse_error
			if !e.nil?
				record.errors.add 'CSS', "has an error - #{e}.  If you need help, post your code at http://forum.userstyles.org/discussion/34614/new-css-parservalidator" unless e.nil?
			else
				record.errors.add 'CSS', "looks unintentionally global. Please read https://github.com/JasonBarnabe/stylish/wiki/Preventing-global-styles ." if record.calculate_unintentional_global
				namespaces = record.calculate_namespaces
				if !namespaces.nil?
					bad_namespaces = namespaces - ['http://www.w3.org/1999/xhtml', 'http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul', 'http://docbook.org/ns/docbook', 'http://www.w3.org/2000/svg', 'http://www.gribuser.ru/xml/fictionbook/2.0', 'http://vimperator.org/namespaces/liberator']
					if bad_namespaces.length == 1
						record.errors.add 'CSS', "has an invalid namespace: #{bad_namespaces.first}. Read https://github.com/JasonBarnabe/stylish/wiki/CSS-namespaces for info on namespaces."
					elsif bad_namespaces.length > 1
						record.errors.add 'CSS', "has invalid namespaces: #{bad_namespaces.join(', ')}. Read https://github.com/JasonBarnabe/stylish/wiki/CSS-namespaces for info on namespaces."
					end
				end
				
			end
		else
			code_error = nil
			record.code_possibilities.each do |a|
				p = a[0]
				cp = a[1]
				# first, check the parser. if it's cool, then we're cool. if it fails, then we'll do some manual checks
				begin
					CSSPool::CSS::Document.parse(cp)
				#rescue Racc::ParseError => e
				rescue Exception => e
					potential_code_error = "has an error - #{e}"
					# check the number of brackets
					if cp.count("{") == 0 or cp.count("{") != cp.count("}")
						code_error = potential_code_error
						break
					end
					# must have at least one colon
					if cp.count(":") == 0
						code_error = potential_code_error
						break
					end
					# can't be html (start with open bracket)
					html_match = cp.match(/^\s*</)
					if !html_match.nil? and html_match.begin(0) == 0
						code_error = potential_code_error
						break
					end
					# can't be JS (start with double slashes)
					js_match = cp.match(/^\s*\/\//)
					if !js_match.nil? and js_match.begin(0) == 0
						code_error = potential_code_error
						break
					end
				end
			end
			record.errors.add attr, code_error if !code_error.nil?
		end
		
		record.calculate_moz_docs.each do |fn, value|
			record.errors.add 'CSS', "has an invalid @-moz-document value: #{fn} #{value}. Read https://github.com/JasonBarnabe/stylish/wiki/Valid-@-moz-document-rules for more info." if !self.validate_moz_doc(fn, value)
		end
	end
	
	# Move child record errors onto main
	validate do |style|
		style_filtered_errors = style.errors.reject{ |attr, msg| ['style_options', 'style_option_values', 'style_code', 'screenshots'].include?(attr) and msg.include?('is invalid') }
		style.errors.clear
		style_filtered_errors.each { |err| style.errors.add(*err) }
		style.style_options.each do |so|
			so.errors.each do |attr, msg|
				style.errors.add("Style option #{attr}", msg) unless attr == 'style_option_values'
			end
			so.style_option_values.each do |sov|
				sov.errors.each do |attr, msg|
					style.errors.add("Style option value #{attr}", msg)
				end
			end
		end
		style.style_code.errors.each do |attr, msg|
			style.errors.add("Code", msg)
		end
		style.screenshots.each do |screenshot|
			screenshot.errors.each do |attr, msg|
				style.errors.add("Screenshot", msg)
			end
		end
	end

	define_index do
		# fields
		indexes short_description, :as => :name, :sortable => true
		indexes long_description, :as => :description
		indexes additional_info
		indexes category
		indexes 'IF(ISNULL(subcategory), "none", subcategory)', :as => :subcategory
		indexes user.name, :as => :author
    
		# attributes
		has :popularity_score, :as => :popularity
		has :created, :updated, :total_install_count, :weekly_install_count, :rating

		where 'obsolete = 0'

		set_property :field_weights => {
			:subcategory => 10,
			:name => 5,
			:author => 5,
			:description => 2,
			:additional_info => 1
		}

		set_property :delta => :delayed
	end

	@search_columns = ["short_description", "long_description", "additional_info"]
	
	# used when validating, because setting on the real property saves immediately
	@_tmp_style_options = nil
	def tmp_style_options
		@_tmp_style_options
	end
	def tmp_style_options=(tso)
		@_tmp_style_options = tso
	end
	def real_style_options
		@_tmp_style_options.nil? ? style_options : @_tmp_style_options
	end

	attr_accessor :rating_avg, :rating_count

	def is_css_valid?
		if self.style_code.code.count("{") > 0 and self.style_code.code.count("{") == self.style_code.code.count("}") and self.style_code.code.count(":") > 0
			return true
		end
		return false
	end

	def self.newly_added(category, limit)
		return Style.find(:all, :order => "created DESC", :limit => limit, :conditions => "created > #{1.week.ago.strftime('%Y-%m-%d')} AND obsolete = 0 " + (category.nil? ? "" : " AND category = '#{category}'"))
	end

	def related
		return nil if id.nil?
		conditions = "id != #{self.id} AND obsolete = 0 AND "
		if !subcategory.nil?
			conditions += "subcategory = '#{Style.connection.quote_string(subcategory)}'"
		else
			conditions += "category = '#{Style.connection.quote_string(category)}'"
		end
		return Style.find(:all, :conditions => conditions, :order => "user_id = #{user.id} DESC, popularity_score DESC", :limit => 3)
	end

	def self.top_styles(limit, choose_from)
		#get the nth highest rated style
		#rows = Style.find_by_sql("select id from styles where obsolete = 0 order by popularity_score DESC LIMIT #{choose_from};")
		#style_ids = []
		#rows.each do |row|
		#	style_ids << row.id
		#end
		#return Style.find(:all,	 :conditions => "styles.id IN (#{style_ids.join(',')})", :order=> "RAND() DESC")

		#grab the top n
		possibilities = Style.find(:all, :conditions => "obsolete = 0", :order => "popularity_score DESC", :limit => choose_from)
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
			if styles.size >= limit
				return styles
			end
		end
		# fill in the rest with whatever
		i = 0
		while styles.size < limit
			styles << possibilities[i] unless styles.include?(possibilities[i])
			i = i + 1
		end
		return styles
	end

	def self.subcategories(category)
		self.connection.select_all("SELECT subcategory name, SUM(weekly_install_count) installs FROM styles WHERE #{self.sanitize_sql(:category => category)} AND subcategory IS NOT NULL GROUP BY subcategory ORDER BY installs DESC LIMIT 20")
	end

	$namespace_pattern = /^\s*@namespace\s+((url\()|['"])[^"')]+(\)|['"]);?$/i
	def userjs(options)
		has_global = false
		has_non_includable = false
		includes = []

		sc = StyleCode.new
		sc.code = optionned_code(options)
		return nil if sc.code.nil?
		sections = sc.parse_moz_docs

		# if the only global part is a default namespace, we'll strip that out to keep
		global_sections = sections.select {|section| section[:global] }
		if global_sections.size == 1
			sections.delete(global_sections[0]) unless global_sections[0][:code].match($namespace_pattern).nil?
		end

		sections.each do |section|
			#puts "=====#{section[:global]} #{section[:rules].nil? ? '' : section[:rules].length} #{section[:code]}\n\n"
			if section[:global]
				has_global = true
			else
				section[:rules].each do |moz_doc_rule|
					js_includes = moz_doc_rule.to_userjs_includes
					if js_includes.nil?
						has_non_includable = true
					else
						includes.concat(js_includes)
					end
				end
			end
			section[:code].gsub!(/\\/, '\&\&')
			section[:code].gsub!('"', '\"')
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
			string += "var css = \"#{sections[0][:code].gsub(/(\r\n|[\r\n])/, '\n')}\";\n"
		else
			string += "var css = \"\";\n"
			sections.each do |section|
				if !section[:global]
					string += "if (false"
					section[:rules].each do |rule|
						case rule.rule_type
							when 'domain'
								string += " || (document.domain == \"#{escape_javascript(rule.value)}\" || document.domain.substring(document.domain.indexOf(\".#{escape_javascript(rule.value)}\") + 1) == \"#{escape_javascript(rule.value)}\")"
							when 'url'
								string += " || (location.href.replace(location.hash,'') == \"#{escape_javascript(rule.value)}\")"
							when 'url-prefix'
								string += " || (document.location.href.indexOf(\"#{escape_javascript(rule.value)}\") == 0)"
							when 'regexp'
								# we want to match the full url, so add ^ and $ if not already present
								re = rule.value
								re = '^' + re unless re.start_with?('^')
								re = re + '$' unless re.end_with?('$')
								string += " || (new RegExp(\"#{escape_javascript(re)}\")).test(document.location.href)"
						end
					end
					string += ")\n\t"
				end
				string += "css += \"#{section[:code].gsub(/(\r\n|[\r\n])/, '\n')}\";\n"
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
		return false if self.style_code.nil?
		return false if !self.style_options.empty?
		return false if self.category == 'app'
		sections = style_code.parse_moz_docs
		if sections.length == 0 or sections.length > 2
			return false
		end
		# multiple sections is only acceptable if one is just a namespace
		if sections.length == 2
			non_namespace = sections.reject {|section| !section[:code].match($namespace_pattern).nil?}
			if non_namespace.empty? or non_namespace.size == 2
				return false
			end
			section = non_namespace[0]
		else
			section = sections[0]
		end
		if section[:global]
			return true
		end
		return true
	end

	def calculate_opera_css_available?
		return false if self.style_code.nil?
		return false if self.category == 'app'
		sections = style_code.parse_moz_docs
		return false if sections.length == 0 or sections.length > 2
		# multiple sections is only acceptable if one is just a namespace
		if sections.length == 2
			non_namespace = sections.reject {|section| !section[:code].match($namespace_pattern).nil?}
			if non_namespace.empty? or non_namespace.size == 2
				return false
			end
			section = non_namespace[0]
		else
			section = sections[0]
		end
		if section[:global]
			return true
		end
		section[:rules].each do |rule|
			if rule.rule_type != 'domain'
				return false
			end
		end
		return true
	end

	def calculate_chrome_json_available?
		self.category != 'app'
	end

	def ie_css
		css = "/*\n\t@homepage http://userstyles.org/styles/#{id}\n" +
			"\t@updateurl http://userstyles.org/styles/iecss/#{id}/#{URI.escape(short_description, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}.css\n"
		moz_docs = style_code.parse_moz_docs
		moz_docs.each do |section|
			if !section[:global]
				section[:rules].each do |rule|
					css += "\t@#{rule.rule_type} #{rule.value}\n"
				end
			end
		end
		css += "*/\n"
		moz_docs.each do |section|
			css += section[:code]
		end
		return css
	end

	def opera_css(options)
		css = "/*\n\t#{short_description}\n\tBy #{user.name}\n\thttp://userstyles.org/styles/#{id}\n*/\n"
		sc = StyleCode.new
		sc.code = optionned_code(options)
		sections = sc.parse_moz_docs
		# charset must be first, even before the comment
		if !sections.empty?
			charset = sections[0][:code].match(/^@charset\s+["'][-A-Za-z0-9]+["']\s*;/m)
			if !charset.nil?
				css = charset[0] + "\n" + css + "\n" + sections[0][:code].sub(charset[0], '')
				# first section is handled
				sections = sections.slice(1, sections.length - 1)
			end
		end
		sections.each do |section|
			css += "\n" + section[:code]
		end
		return css
	end

	def chrome_json(options)
		o = {:sections => []}
		global_sections = []
		sc = StyleCode.new
		sc.code = optionned_code(options)
		return nil if sc.code.nil?
		sc.parse_moz_docs.each do |section|
			s = {:urls => [], :urlPrefixes => [], :domains => [], :regexps => []}
			s[:code] = section[:code].strip
			#puts "\n\nglobal#{section[:global]}"
			if !section[:global]
				section[:rules].each do |rule|
					case rule.rule_type
						when 'domain'
							s[:domains] << rule.value
						when 'url'
							s[:urls] << rule.value
						when 'url-prefix'
							s[:urlPrefixes] << rule.value
						when 'regexp'
							s[:regexps] << rule.value
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
		if style_options.empty?
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
		begin
			Style.connection.execute("INSERT INTO daily_install_counts (style_id, ip, source) VALUES (#{Style.connection.quote_string(style_id)}, '#{Style.connection.quote_string(ip)}', '#{Style.connection.quote_string(source)}');")
		rescue ActiveRecord::StatementInvalid
			# user already installed
		end
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
		return 'last.fm' if sld = 'lastfm'
		return sld
	end

	def self.get_domain(url)
		#the part after :// but before the next slash
		scheme_end = url.index("://")
		if scheme_end != nil
			url = url[scheme_end + 3..url.length]
		end
		#before the first : or /
		domain_end = url.index(/[\:\/]/)
		if domain_end != nil
			url = url[0..domain_end - 1]
		end
		# handle trailing dots: add com
		url.gsub!(/\.$/, ".com")
		# handle people doing url-prefix(http://www.google)
		domain_parts = url.split('.')
		if domain_parts.size > 1 
			if $add_com_tlds.include?(domain_parts[domain_parts.length - 1])
				url = url + '.com'
			elsif $add_org_tlds.include?(domain_parts[domain_parts.length - 1])
				url = url + '.org'
			end
		end
		return nil unless url.match($bad_domains).nil?
		return url
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
		errors << [name, "is too big, must be under 100KB"] if size > 100 * 1024
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
				File.delete("#{RAILS_ROOT}/public/style_screenshots/#{get_screenshot_name_by_type(type)}")
			rescue Errno::ENOENT
				#no file. meh.
			rescue Errno::EISDIR
				#the name must've been blank, so we're referring to the directory. meh.
			end
			if type == :after
				begin
					File.delete("#{RAILS_ROOT}/public/style_screenshot_thumbnails/#{get_screenshot_name_by_type(type)}")
				rescue Errno::ENOENT
					#no file. meh.
				rescue Errno::EISDIR
					#the name must've been blank, so we're referring to the directory. meh.
				end
			end
		end
		filename = "#{self.id}_#{prefix}.#{screenshot.content_type.strip.split('/')[1]}"
		File.open("#{RAILS_ROOT}/public/style_screenshots/#{filename}", "w") { |f| f.write(screenshot.read) }
		refresh_cdn "/style_screenshots/#{filename}" if is_update
		if type == :after
			`#{RAILS_ROOT}/thumbnail.sh #{RAILS_ROOT}/public/style_screenshots/#{filename} #{RAILS_ROOT}/public/style_screenshot_thumbnails/#{filename} &> #{RAILS_ROOT}/thumb.log`
			refresh_cdn "/style_screenshot_thumbnails/#{filename}" if is_update
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
		full_path = "#{RAILS_ROOT}/public/style_screenshots/#{filename}"
		is_update = File.exists?(full_path)
		File.open(full_path, "w") { |f| f.write(data.read) }
		refresh_cdn "/style_screenshots/#{filename}" if is_update
	end

	def refresh_cdn(path)
		`#{RAILS_ROOT}/refresh_cdn.sh http://#{STATIC_DOMAIN}#{path} >> #{RAILS_ROOT}/refresh_cdn.log 2>> #{RAILS_ROOT}/refresh_cdn.log`
	end

	def delete_additional_screenshot(screenshot)
		begin
			File.delete("#{RAILS_ROOT}/public/style_screenshots/#{screenshot.path}", "w")
		rescue Errno::ENOENT
			#no file. meh.
		end
		screenshot.delete
	end

	def change_additional_screenshot(screenshot, data)
		begin
			File.delete("#{RAILS_ROOT}/public/style_screenshots/#{screenshot.path}", "w")
		rescue Errno::ENOENT
			#no file. meh.
		end
		filename = "#{self.id}_additional_#{screenshot.id}.#{data.content_type.strip.split('/')[1]}"
		screenshot.path = filename
		screenshot.save!
		File.open("#{RAILS_ROOT}/public/style_screenshots/#{filename}", "w") { |f| f.write(data.read) }
	end

	# applies the style options to this style. the parameter is a hash of string style option id to (string style value id | text value)
	def optionned_code(params)
		#raise "#{params.inspect}" if params["214001"] == "979983"
		c = style_code.code.dup
		so = real_style_options
		# nest this two levels deep
		2.times do
			so.each do |option|
				# missing an option?
				return nil unless params.include?(option.parameter_id.to_s)
				if option.option_type == "color" or option.option_type == "image"
					# we need to escape any backslashes in the *replacement* value, as things like \0 are interpreted as regex groups. we're escaping them to 2 backslashes, which gets doubled to 4 when interpreted by the regex system, then 8 by being a ruby string
					c.gsub!("/*[[#{option.name}]]*/", params[option.parameter_id.to_s].gsub('\\','\\\\\\\\'))
				elsif option.option_type == "dropdown"
					selected_values = option.style_option_values.select {|v| v.parameter_id.to_s == params[option.parameter_id.to_s].to_s}
					if !selected_values.empty?
						# ditto above
						c.gsub!("/*[[#{option.name}]]*/", selected_values[0].value.gsub('\\','\\\\\\\\'))
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

	def after_screenshot_path
		return auto_after_screenshot_path if self.screenshot_type_preference == 'auto'
		return provided_after_screenshot_path if self.screenshot_type_preference == 'manual'
		return nil
	end

	def auto_after_screenshot_path
		return "/auto_style_screenshots/#{self.id}-after.png" unless self.auto_screenshot_date.nil? or self.auto_screenshots_same
		return nil
	end

	def provided_after_screenshot_path
		return "/style_screenshots/#{self.after_screenshot_name}" unless self.after_screenshot_name.nil?
	end

	def full_after_screenshot_thumbnail_path
		return nil if after_screenshot_thumbnail_path.nil?
		return 'http://' + STATIC_DOMAIN + after_screenshot_thumbnail_path
	end

	def after_screenshot_thumbnail_path
		return nil if self.screenshot_type_preference == 'auto' and self.auto_screenshots_same
		return auto_after_screenshot_thumbnail_path if self.screenshot_type_preference == 'auto'
		return provided_after_screenshot_thumbnail_path if self.screenshot_type_preference == 'manual'
		return nil
	end

	def provided_after_screenshot_thumbnail_path
		return "/style_screenshot_thumbnails/#{self.after_screenshot_name}" unless self.after_screenshot_name.nil?
		return nil
	end

	def auto_after_screenshot_thumbnail_path
		return "/auto_style_screenshots/#{self.id}-after-thumbnail.png" unless self.auto_screenshot_date.nil?
		return nil
	end

	def write_md5
		filename = "#{MD5_PATH}#{self.id}.md5"
		if !self.redirect_page.nil? or !self.style_options.empty? or self.style_code.nil?
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

  def to_json(options = nil)
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
			:screenshot => full_after_screenshot_thumbnail_path,
			:license => effective_license_url
		}.to_json(options)
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
		option_possibilities = real_style_options.map { |option| option.possibilities }
		defaults = option_possibilities.map { |p| p.first }
		value_possibilities = [defaults]
		(0..option_possibilities.size-1).each do |i|
			# if there's other options than the first, let's try them all out
			if option_possibilities[i].size > 1
				(1..option_possibilities[i].size-1).each do |j|
					values = Array.new(defaults)
					values[i] = option_possibilities[i][j]
					value_possibilities << values
				end
			end
		end

		#puts "#{value_possibilities.length} values\n"
		codes = []
		value_possibilities.each do |p|
			param_has = {}
			(0..real_style_options.length-1).each do |i|
				param_has[real_style_options[i].parameter_id.to_s] = p[i]
			end
			codes << [param_has, optionned_code(param_has)]
		end
		return codes.first($possibilities_limit)
	end

	$possibilities_limit = 25
	# returns an array of (options, code) for all possibilities for this style (due to options). 
	def code_possibilities
		return [] if style_code.nil?
		return [[{}, style_code.code]] if real_style_options.empty?
		
		#puts "checking options\n"
		option_possibilities = real_style_options.map { |option| option.possibilities }

		# let's see if this going to be a reasonable number. if it's unreasonable, we'll be lazy
		total_count = 1
		option_possibilities.each do |p|
			total_count = total_count * p.size
		end
		#puts "#{total_count} combinations\n"
		return lazy_code_possibilities if total_count > $possibilities_limit

		#puts "creating combinations\n"
		value_possibilities = nil
		option_possibilities.each do |p|
			if value_possibilities.nil?
				value_possibilities = p.map {|v| [v]}
			else
				value_possibilities = value_possibilities.product(p)
			end
		end
		#puts "#{value_possibilities.length} value_possibilities"
		codes = []

		#puts "creating codes\n"
		value_possibilities.each do |p|
			param_has = {}
			p.flatten!
			(0..real_style_options.length-1).each do |i|
				param_has[real_style_options[i].parameter_id.to_s] = p[i]
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
			CSSPool::CSS::Document.parse(code)
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
		return style_code.old_style_rules.map{|mdr| [mdr.rule_type, mdr.value]} if docs.nil?
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

 private

	# Returns an array of all docs for this style, or nil if any are invalid
	# Cache the docs for the life of the request so we don't have to keep reparsing. If the code or settings 
	# change, then don't return the cached copy.
	@_cached_docs = nil
	@_cached_doc_code_hash = nil
	def get_docs_or_nil
		return nil if style_code.nil?
		return @_cached_docs if (!@_cached_docs.nil? and @_cached_doc_code_hash == style_code.code.hash + real_style_options.hash)
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
		@_cached_doc_code_hash = style_code.code.hash + real_style_options.hash
		#logger.debug "done docs"
		return docs
	end
 
	def self.get_doc_or_nil(code)
		begin
			return CSSPool::CSS::Document.parse(code)
		rescue Exception => e
			return nil
		end
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
				return true if !(value =~ /^(http|https|file|ftp):?\/*/).nil?
				return false if (value =~ URI::regexp(%w(http https file ftp))).nil?
				begin
					url_value = URI.parse(value)
				rescue
					return false
				end
				return Style.validate_domain(url_value.host, false)
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

end
