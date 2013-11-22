require 'set'
require 'will_paginate'

class StylesController < ApplicationController

	helper :users
	helper :categories

	cache_sweeper :style_sweeper

	$bad_content_subcategories = ["keezmovies", "xvideos", "jizzhut", "pornhub", "redtube", "tube8", "xnxx", "youjizz", "geisha-porn", "4tube", "xhamster", "youporn", "pussy", "imagefap", "pornbits", "xvideosadult", "youskbe", "moez-m", "dokidokibox", "emflix", "erogeba", "eromate", "xxeronetxx", "exploader", "hardsextube", "iqoo", "lovemake", "pornhost", "shufuni", "slutload", "spankwire", "xxxblog", "xvideosmovie", "free-sexvideosfc2", "yaaabooking", "yvhmovie", "oshirimania", "fakku", "e-hentai", "skins", "megaporn", "pussytorrents", "empflix", "xvideos-userporn", "xvideos-porn", "xvideos-collector", "exhentai", "sextube", "yobt", "asstr", "scor", "pornotube", "pornbb", "iafd", "artinude", "motherless", "keyboardporn", "empornium", "eporner", "freeporn", "fritchy", "lettherebeporn", "literotica", "masterporn", "mywebporno", "peniscult", "saff", "porn-w", "pornerbros", "porntown", "sexotorrent", "userporn", "vintage-erotica-forum", "wkdporn", "xxx-tracker", "livejasmin", "myfreecams", "cheggit", "dumparump", "fapomatic", "playboy", "bareback", "brazzers", "hentairules", "h-zip", "sankakucomplex",  "gelbooru", "konachan", "donmai", "gz-loader", "pinktower", "artemisweb", "suomi-neito", "tokyo-tube", "nukistream", "elog-ch", "adultghibli", "fleshbot", "ascii2d", "doujin-loli-school", "daimajin", "chaturbate", "cam4", "danshiryo", "yuvutu", "mcstories",  "storiesonline", "bestgfe", "stripclublist", "fuskator", "4gifs", "amateurindex", "freeones", "playboy", "adultfanfiction", "hi5", "minkch", "yande", "sexinsex", "eroino", "perfectgirls", "cpz", "ecchi", "eromodels", "erolight", "erolash", "nijie", "okazu24", "bravoteens", "tblop", "elephanttube", "pumbaporn", "pinkworld", "zegaporn", "abcpornsearch", "forhertube", "wtchporn", "1000mg", "sexfotka", 'yiff', 'fetlife', 'rule34']
	$tld_specific_bad_domains = ["dmm.co.jp"]
	$bad_words = ['porn', 'erotic', 'porno', 'booty', 'nude', 'sexo', 'naked', 'bondage', 'jizz', 'milf', 'jailbait', 'fag', 'nsfw', 'sex', 'sexy', 'boob', 'boobs', 'tits', 'cock', 'penis', 'vagina', 'fap', 'fapping', 'masturbate', 'hentai', 'slut', 'sluts', 'whore', 'whores', 'anus', 'bollock', 'boner', 'clit', 'condom', 'crotch', 'cunt', 'dildo', 'furaffinity' ,'horny', 'ecchi'] + $bad_content_subcategories - ['skins']
	$iffy_words = ['babe', 'girl', 'underwear', 'panty', 'panties'] + $bad_words

	def show
		respond_to do |format|
			format.html {
				if request.remote_ip == '74.117.177.181'
					redirect_to '/getstyles/0.html', :status => 301
					return
				end
				begin
					@style = Rails.cache.fetch "styles/show/#{params[:id]}" do
						Style.includes([:user, {:style_options => :style_option_values}, :screenshots, :admin_delete_reason, {:discussions => {:original_forum_poster => :users}}]).find(params[:id])
					end
				rescue ActiveRecord::RecordNotFound
					render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => true
					return
				end
				if !@style.redirect_page.nil?
					redirect_to @style.redirect_page, :status => 301
					return
				end
				if !@style.admin_delete_reason.nil? and @style.admin_delete_reason.locked
					render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => true
					return
				end
				bad_content = $bad_content_subcategories.include?(@style.subcategory)
				if bad_content
					render :nothing => true, :status => 404
					return
				end
				if @style.pretty_url != request.path
					if request.query_string.nil? or request.query_string.empty?
						redirect_to @style.pretty_url, :status => 301
					else
						redirect_to @style.pretty_url + '?' + request.query_string, :status => 301
					end
					return
				end
				@page_title = @style.short_description
				@page_header = @style.short_description
				@page_title = @page_title + " - Themes and Skins for " + @style.subcategory.capitalize unless @style.subcategory.nil?
				@header_include = "<link rel='stylish-code' href='#{url_for(:id => params['id'], :host => DOMAIN)}.css'/>\n<script>document.querySelector(\"link[rel='stylish-code']\").setAttribute('href', '#stylish-code');</script>\n<link rel='stylish-description' href='#stylish-description'/>\n".html_safe
				if @style.style_options.empty? 
					@header_include += "<link rel='stylish-md5-url' href='http://#{UPDATE_DOMAIN}/#{@style.id}.md5'/>\n<link rel='stylish-update-url' href='#{url_for(:id => params['id'], :host => DOMAIN)}.css'/>\n".html_safe
				else
					@style.style_options.each do |option|
						if option.option_type == "color"
							@header_include += "<script type='text/javascript' src='http://#{STATIC_DOMAIN}/javascripts/jscolor.js'></script>\n".html_safe
							break
						end
					end
				end
				@header_include += "<link rel=\"stylish-install-ping-url\" href=\"#{url_for(:action => 'install', :id => params['id'], :source => 'stylish-fx', :host => DOMAIN)}\">\n<link rel=\"stylish-install-ping-url-chrome\" href=\"#{url_for(:action => 'install', :id => params['id'], :source => 'stylish-ch', :host => DOMAIN)}\">\n<link rel=\"stylish-install-ping-url-opera\" href=\"#{url_for(:action => 'install', :id => params['id'], :source => 'stylish-op', :host => DOMAIN)}\">\n<link rel=\"stylish-code-ie\" href=\"#{CGI.escapeHTML(url_for(:action => 'ie_css', :id => @style.id, :foo => @style.short_description, :host => DOMAIN))}\">\n<link rel=\"stylish-code-chrome\" href=\"#{CGI.escapeHTML(url_for(:action => 'chrome_json', :id => @style.id, :host => DOMAIN))}\">\n<link rel=\"stylish-code-opera\" href=\"#{CGI.escapeHTML(url_for(:action => 'chrome_json', :id => @style.id, :host => DOMAIN))}\">\n<link rel=\"stylish-id-url\" href=\"http://#{DOMAIN}/styles/#{@style.id}\">\n".html_safe
				if !@style.screenshot_url.nil?
					@header_include += "<link rel=\"stylish-example-url\" href=\"#{CGI.escapeHTML(@style.screenshot_url)}\">".html_safe
				end
				if @style.subcategory.nil?
					@meta_description = "Customize your web browser with this user style." 
				else
					@meta_description = "Customize your #{@style.subcategory} experience with this user style." 
				end
				@canonical = @style.full_pretty_url
				@feeds = []
				@feeds << {:title => @style.short_description, :href => "/styles/#{@style.id}.json", :type => "application/json"}
				if @style.obsolete?
					@no_ads = true
					@no_bots = true
				end
			}
			format.css {
				if request.remote_ip == '74.117.177.181'
					redirect_to '/getstyles/0.css', :status => 301
					return
				end
				begin
					style = Style.includes([:style_code, {:style_options => :style_option_values}]).find(params[:id])
				rescue ActiveRecord::RecordNotFound
					render :nothing => true, :status => 404
					return
				end
				code = style.optionned_code(get_option_params())
				if code.nil?
					render :nothing => true, :status => 400
				else 
					send_data(code, :type => "text/css", :disposition => "inline")
				end
			}
			format.md5 {
				redirect_to "http://#{UPDATE_DOMAIN}/#{params[:id]}.md5", :status => 301
			}
			format.json {
				if request.remote_ip == '74.117.177.181'
					redirect_to '/getstyles/0.json', :status => 301
					return
				end
				begin
					style = Style.includes([:user, :style_code, {:style_options => :style_option_values}]).find(params[:id])
				rescue ActiveRecord::RecordNotFound
					render :nothing => true, :status => 404
					return
				end
				render :text => style.to_json
			}
		end
	end

	def show_redirect
		redirect_to url_for(:action => :show, :id => params[:id]), :status => 301
	end

	def install
		@no_bots = true
		source = params[:source]
		if source == 'stylish-ch' or source == 'stylish-fx' or source == 'stylish-op'
			Style.increment_installs(params[:id], source, request.remote_ip)
		end
		render :nothing => true, :status => 200
	end

	def new
		@style = Style.new
		@style.user_id = session[:user_id]
		@page_title = "New style"
		@no_bots = true
		@header_include = "<script type='text/javascript' src='http://#{STATIC_DOMAIN}/javascripts/jscolor.js'></script>\n".html_safe
		render :action => "edit"
	end

	def edit
		@style = Style.includes(:style_code, :screenshots, {:style_options => :style_option_values}).find(params["id"])
		@no_bots = true
		@page_title = "Editing " + @style.short_description
		@header_include = "<script type='text/javascript' src='http://#{STATIC_DOMAIN}/javascripts/jscolor.js'></script>\n<script type='text/javascript' src='http://#{STATIC_DOMAIN}/javascripts/lightbox.js'></script>\n".html_safe
	end

	def create
		handle_change(true)
	end

	def update
		handle_change(false)
	end

	def search_url
		redirect_to :action => 'browse', :category => params[:category], :search_terms => params[:id], :sort => 'popularity', :sort_direction => 'desc', :page => 1, :status => 301
	end

	def search_text
		redirect_to :action => 'browse', :category => params[:category], :search_terms => params[:id], :sort => 'popularity', :sort_direction => 'desc', :page => 1, :status => 301
	end

	def search
		redirect_to :action => 'browse', :category => params[:category], :search_terms => params["search-terms"] || params[:id], :sort => 'popularity', :sort_direction => 'desc', :page => 1, :status => 301
	end

	def browse_r
		original_category = params[:category]
		fix_search_url(params)
		options = {:controller => 'styles', :action => 'browse', :page => params[:page], :status => 301}
		options[:search_terms] = params[:search_terms] unless (!params[:search_terms].nil? and params[:search_terms] == '')
		# keep advanced search if set. if we calculated a category, perform advanced search, but don't show the ui
    calculated_category = (original_category.nil? or original_category == 'all') and !(params[:category].nil? or params[:category] == 'all')
		if !params[:as].nil? or calculated_category
			options[:as] = 1 unless calculated_category
			options[:category] = params[:category] unless (!params[:category].nil? and params[:category] == '')
			options[:format] = params[:format] unless (!params[:format].nil? and params[:format] == '')
			options[:per_page] = params[:per_page] unless (!params[:per_page].nil? and (params[:per_page] == '' or params[:per_page].to_i == 10))
			if (!params[:sort].nil? and params[:sort] != 'relevance') or (!params[:sort_direction].nil? and params[:sort_direction] != 'desc')
				options[:sort] = params[:sort]
				options[:sort_direction] = params[:sort_direction]
			end
		end
		redirect_to options
	end

	def browse
		# old url format
		if !params[:page_o].nil?
			params[:page] = params[:page_o]
			params[:page_o] = nil
		end

		#condition = 'obsolete = 0'
		#first_domain = nil
		options = {:page => params[:page]}#, :include => []}

		# default params
		if params[:sort] == 'relevance' and params[:sort_direction] == 'desc'
			params[:sort] = nil
			params[:sort_direction] = nil
		end
		if params[:page] == '1'
			params[:page] =  nil
		end
		if params[:per_page] == '10'
			params[:per_page] =  nil
		end
		if params[:category] == 'all'
			params[:category] = nil
		end

		if fix_search_url(params)
			browse_r
			return
		end

		bad_word_search = false
		search_terms = params[:search_terms]
		search_terms.strip! unless search_terms.nil?

		# oh google, i hate you so
		bad_word_search = true if search_terms == "Page d'accueil"

		keywords = nil
		if !search_terms.nil? and !search_terms.empty?
			keywords = search_terms.split(' ') - ['skin', 'theme', 'layout', 'style', 'for', 'the']	
			keywords = keywords.join(' ')
			# check for bad stuff
			l_keywords = keywords.downcase
			$bad_words.each do |bw|
				bad_word_search = true if l_keywords.include?(bw)
			end
		end

		new_search_conditions = {}
		category = params[:category]
		if category.nil?
			#no category restrictions
		elsif !['global','app','site'].index(category).nil?
			@bc_category = category
			new_search_conditions[:category] = category
		elsif category == 'appnone'
			#condition += " AND category = 'app' AND subcategory IS NULL"
			new_search_conditions[:category] = 'app'
			new_search_conditions[:subcategory] = 'none'
		elsif category == 'sitenone'
			#condition += " AND category = 'site' AND subcategory IS NULL"
			new_search_conditions[:category] = 'site'
			new_search_conditions[:subcategory] = 'none'
		elsif category == 'globalnone'
			#condition += " AND category = 'global' AND subcategory IS NULL"
			new_search_conditions[:category] = 'global'
			new_search_conditions[:subcategory] = 'none'
		else
			@bc_category = 'site'
			category = Style.get_subcategory_for_domain(category)
			@bc_subcategory = category
			new_search_conditions[:subcategory] = Riddle.escape(category)
		end

		if !$new_sorts_map.keys.include?(params[:sort])
			params[:sort] = nil
		end
		sort = $new_sorts_map[params[:sort] || 'relevance']

		sort_direction = params[:sort_direction].nil? ? 'desc' : params[:sort_direction].downcase
		if sort_direction != 'desc'
			sort_direction = 'asc'
		end
		options[:order] = "#{sort} #{sort_direction}"#, styles.id #{sort_direction}"

		if !params[:per_page].nil? and params[:per_page].to_i > 0 and params[:per_page].to_i <= 200
			options[:per_page] = params[:per_page].to_i
		else
			options[:per_page] = 10
			params[:per_page] = nil
		end

		# weight is irrelevant when there are no terms
		if keywords.nil? and sort == 'myweight DIR, popularity DIR'
			new_sort = $new_sorts_map['popularity']
		else
			new_sort = sort
		end
		begin 
			@styles = Style.search keywords, :match_mode => :extended, :page => params[:page], :order => new_sort.gsub('DIR', sort_direction.upcase), :per_page => options[:per_page], :conditions => new_search_conditions, :populate => true, :select => 'weight() myweight'
			@no_ads = @styles.empty?
		#rescue ThinkingSphinx::SphinxError => e
			# back to the main listing, unless we're already there
		#	raise e if params[:category].nil? and params[:search_terms].nil? and params[:page].nil? and params[:order].nil? and params[:sort].nil? and params[:sort_direction].nil?
		#	redirect_to :controller => 'styles', :action => 'browse', :category => nil, :search_terms => nil
		#	return
		rescue Riddle::OutOfBoundsError
			# same url, minus the page param
			redirect_to :controller => 'styles', :action => 'browse', :search_terms => params[:search_terms], :category => params[:category], :format => params[:format], :sort => params[:sort], :sort_direction => params[:sort_direction]
			return
		end
			
		if search_terms.nil?
			if !category.nil?
				c = category
				c = 'app' if c == 'appnone'
				@page_title = "#{c.capitalize} themes and skins"
				@meta_description = "A listing of #{c.capitalize} user styles."
			elsif sort == 'myweight DIR, popularity DIR' and sort_direction == 'desc'
				@page_title = 'Top themes and skins'
				@meta_description = "A listing of the top user styles that you can customize your browser with." 
			elsif sort == 'updated DIR' and sort_direction == 'desc'
				@page_title = 'Updated themes and skins'
				@meta_description = "A listing of the most recently updated user styles that you can customize your browser with." 
			elsif sort == 'created DIR' and sort_direction == 'desc'
				@page_title = 'New themes and skins'
				@meta_description = "A listing of the newest user styles that you can customize your browser with." 
			else
				@page_title = 'Theme and skin search results'
				@meta_description = "A listing of user styles." 
			end
		else
			if !category.nil?
				c = category
				c = 'app' if c == 'appnone'
				@page_title = "#{c.capitalize} #{search_terms} themes and skins"
				@meta_description = "A listing of #{c.capitalize} #{search_terms} user styles you can customize your browser with." 
			else
				@page_title = "#{search_terms} themes and skins"
				@meta_description = "A listing of #{search_terms} user styles you can customize your browser with." 
			end
		end

		@chosen_sort = params[:sort].nil? ? 'relevance' : params[:sort]
		@direction = params[:sort_direction].nil? ? 'desc' : params[:sort_direction].downcase
		@no_bots = !(@chosen_sort == 'relevance' && @direction == 'desc' && (params[:per_page].nil? or params[:per_page].to_i == 10))
		@no_index_but_follow = !params[:page].nil? && params[:page] != '1'

		feed_category = params[:category]
		feed_category = 'all' if feed_category.nil? and !params[:search_terms].nil?

		respond_to do |format|
			format.html {
				if $bad_content_subcategories.include?(feed_category) or bad_word_search
					render :nothing => true, :status => 404
					return
				end
				@feeds = []
				@feeds << {:title => @page_title, :href => url_for(:category => feed_category, :search_terms => params[:search_terms], :sort => params[:sort], :sort_direction => params[:sort_direction], :format => "atom", :host => DOMAIN), :type => "application/atom+xml"}
				@feeds << {:title => @page_title, :href => url_for(:category => feed_category, :search_terms => params[:search_terms], :sort => params[:sort], :sort_direction => params[:sort_direction], :format => "rss", :host => DOMAIN), :type => "application/rss+xml"}
				@feeds << {:title => @page_title, :href => url_for(:category => feed_category, :search_terms => params[:search_terms], :sort => params[:sort], :sort_direction => params[:sort_direction], :format => "json", :host => DOMAIN), :type => "application/json"}
				@feeds << {:title => @page_title, :href => url_for(:category => feed_category, :search_terms => params[:search_terms], :sort => params[:sort], :sort_direction => params[:sort_direction], :format => "jsonp", :host => DOMAIN), :type => "text/javascript"}
				@canonical = url_for(:controller => 'styles', :action => 'browse', :page => params[:page], :category => feed_category, :search_terms => params[:search_terms], :sort => params[:sort] == 'relevance' ? nil : params[:sort], :sort_direction => params[:sort_direction], :per_page => params[:per_page], :format => nil, :host => DOMAIN)
				render :action => 'browse'
			}
			format.rss {
				render(:action => 'style_rss.xml.builder', :content_type => 'application/rss+xml')
			}
			format.atom {
				render(:action => 'style_atom.xml.builder', :content_type => 'application/atom+xml')
			}
			format.json {
				render :text => @styles.to_json
			}
			format.jsonp {
				callback = params[:callback]
				callback = 'handleUserstylesData' if callback.nil? or /^[$A-Za-z_][0-9A-Za-z_\.]*$/.match(callback).nil?
				render :text => callback + '(' + @styles.to_json + ');'
			}
			format.all {
				# something stupid
				redirect_to :controller => 'styles', :action => 'browse', :page => params[:page], :category => feed_category, :search_terms => params[:search_terms], :sort => params[:sort] == 'relevance' ? nil : params[:sort], :sort_direction => params[:sort_direction], :per_page => params[:per_page], :format => nil, :status => 301
			}
		end
	end
	
	def graveyard
		@page_title = 'Style graveyard'
		@no_ads = true
		@no_bots = true
		if !params[:per_page].nil? and params[:per_page].to_i > 0 and params[:per_page].to_i <= 200
			per_page = params[:per_page].to_i
		else
			per_page = 100
		end
		@styles = Style.where('obsolete = 1 and admin_delete_reasons.locked = false').includes([:user, :admin_delete_reason]).references(:admin_delete_reason).order('total_install_count desc, styles.id').paginate(:page => params[:page], :per_page => per_page)
	end

	def delete
		@style = Style.find(params[:id])
		@no_bots = true
		@page_title = "Delete style"
	end

	def delete_save
		@no_bots = true
		@style = Style.find(params["style"]["id"])
		is_delete = params["type"] == "Delete"
		# don't allow undeletion of invalid stuff
		if !is_delete and (!@style.valid? or (!verify_admin_action and !@style.admin_delete_reason.nil? and @style.admin_delete_reason.locked))
			render :action => "edit"
			return
		end
		# don't allow undeletion of locked stuff
		if !is_delete and !verify_admin_action and !@style.admin_delete_reason.nil? and @style.admin_delete_reason.locked
			render :text => "This style cannot be undeleted."
			return
		end
		#a blank obsoleting style is fine, but if it's not blank it has to be valid
		if params["style"]["obsoleting_style_id"].length != 0
			begin
				Style.find(params["style"]["obsoleting_style_id"]) 
			rescue ActiveRecord::RecordNotFound
				@style.errors.add("obsoleting style id")
				@page_title = "Delete style"
				render :action => "delete"
				return
			end
			if params["style"]["obsoleting_style_id"].to_i == @style.id
				@style.errors.add("obsoleting style id")
				@page_title = "Delete style"
				render :action => "delete"
				return
			end
		end
		@style.obsoletion_message = params["style"]["obsoletion_message"]
		@style.obsoleting_style_id = params["style"]["obsoleting_style_id"]
		if is_delete
			@style.obsolete = 1
		else
			@style.obsolete = 0
		end
		# as above, we validated in the case of undelete, but it's ok to delete with validation errors
		@style.save(validate: false)
		redirect_to(:action => "show", :id => @style.id, :r => Time.now.to_i)
	end
	
	def admin_delete
		@style = Style.find(params[:id])
		@no_bots = true
		@page_title = 'Admin delete'
	end
	
	def admin_delete_save
		@style = Style.find(params[:id])
		@no_ads = true
		@no_bots = true
		@style.obsolete = true
		reason = AdminDeleteReason.find(params[:admin_delete_reason_id])
		@style.admin_delete_reason = reason
		@style.obsoletion_message = params[:style][:obsoletion_message]
		if @style.obsoletion_message.nil? or @style.obsoletion_message.empty?
			@style.obsoletion_message = reason.default_message
		end
		#a blank obsoleting style is fine, but if it's not blank it has to be valid
		if params["style"]["obsoleting_style_id"].length != 0
			begin
				Style.find(params[:style][:obsoleting_style_id]) 
			rescue ActiveRecord::RecordNotFound
				@style.errors.add("obsoleting style id")
				@page_title = "Delete style"
				render :action => "admin_delete"
				return
			end
			if params["style"]["obsoleting_style_id"].to_i == @style.id
				@style.errors.add("obsoleting style id")
				@page_title = "Delete style"
				render :action => "admin_delete"
				return
			end
		end
		@style.obsoleting_style_id = params[:style][:obsoleting_style_id]
		@style.save(validate: false)
		redirect_to(:action => "show", :id => @style.id, :r => Time.now.to_i)
	end
	
	def updated
		redirect_to :action => :browse, :format => params[:format], :page => 1, :sort => 'updated_date', :sort_direction => 'desc', :status => 301
	end

	def js
		# we would use post for when we have long params (data: uris). gm does not support via post - https://github.com/greasemonkey/greasemonkey/issues/1673
		# we will store params in flash and redirect to get
		if request.post?
			flash[:settings] = params
			id = params[:id]
			style = Style.find(id)
			redirect_to '/styles/userjs/' + id + '/' + URI.escape(style.short_description.gsub('?', ''), Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) + '.user.js'
			return
		end
		begin
			style = Style.find(params["id"])
		rescue ActiveRecord::RecordNotFound
			render :nothing => true, :status => 404
			return
		end
		if (style.userjs_available)
			Style.increment_installs(params[:id], 'userjs', request.remote_ip)
			code = style.userjs(get_option_params())
			if code.nil?
				render :nothing => true, :status => 400
			else 
				send_data(code, :type => "text/javascript", :disposition => "inline")
			end
		else
			render :nothing => true, :status => 404
		end
	end

	def opera_css
		begin
			style = Style.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			render :nothing => true, :status => 404
			return
		end
		if style.opera_css_available?
			Style.increment_installs(params[:id], 'css-opera', request.remote_ip)
			send_data(style.opera_css(get_option_params()), :type => "text/css", :disposition => "inline")
		else
			render :nothing => true, :status => 404
		end
	end

	def ie_css
		begin
			style = Style.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			render :nothing => true, :status => 404
			return
		end
		if style.ie_css_available?
			send_data(style.ie_css, :type => "text/css", :disposition => "inline")
		else
			render :nothing => true, :status => 404
		end
	end

	def chrome_json
		begin
			style = Style.find(params[:id])
		rescue ActiveRecord::RecordNotFound
			render :nothing => true, :status => 404
			return
		end
		json = nil
		if style.chrome_json_available?
			json = style.chrome_json(get_option_params())
		end
		if json.nil?			
			render :nothing => true, :status => 404
		else
			send_data(json, :type => "application/json", :disposition => "inline")
		end		
	end

	def proxomitron
		begin
			style = Style.find(params["id"])
		rescue ActiveRecord::RecordNotFound
			render :nothing => true, :status => 404
			return
		end
		if (style.userjs_available)
			send_data(style.proxomitron, :type => "text/plain", :disposition => "inline")
		else
			render :nothing => true, :status => 404
		end
	end

	def expire_by_id
		#expire_page(:controller => 'styles', :action => 'show', :id => params[:id])
		StyleSweeper.instance.after_update(Style.find(params[:id]))
		render :nothing => true, :status => 200
	end

	def screenshotable
		bad_content_in = ($bad_content_subcategories.map { |c| "'#{c}'" }).join(',')
		@styles = Style.active.where('screenshot_url is not null ' +
			'and screenshot_type_preference = "auto" ' +
			'and subcategory NOT IN (' + bad_content_in + ')')
			.order('auto_screenshot_date IS NULL DESC, ' + #styles with no screenshot
			'IF(updated >= auto_screenshot_date, DATEDIFF(updated, auto_screenshot_date), -1) DESC, ' + #anything that was updated since the screenshot was generated, the days between the update and the screenshot dates
			'auto_screenshot_date, ' + #last time the screenshot was generated
			'updated DESC') #last time the style was updated
			.limit(1000)
		render :action => "screenshotable", :layout => false
	end

	def automation_page
		@style = Style.includes(:style_code).find(params["id"])
		render :action => "automation_page", :layout => false
	end

	def bad_stuff
		search_columns = ['short_description', 'long_description', 'additional_info', 'users.name', 'users.homepage', 'users.about']
		where = (search_columns.product($iffy_words).map {|c, w| "#{c} LIKE '%#{w}%'"}).join(' OR ')
		ids = Style.connection.select_values("SELECT styles.id FROM styles JOIN users ON styles.user_id = users.id WHERE (#{where}) AND redirect_page IS NULL;")
		if !params[:per_page].nil? and params[:per_page].to_i > 0 and params[:per_page].to_i <= 200
			per_page = params[:per_page].to_i
		else
			per_page = 100
		end
		@styles = Style.paginate(:all, :conditions => "id IN (#{ids.join(',')})", :per_page => per_page, :order => 'updated DESC', :page => params[:page])
		@no_ads = true
		@no_bots = true
		render :action => 'browse'
	end

	def lotsa_screenshots
		if params[:page].nil?
			page = 0
		else
			page = params[:page].to_i
		end
		@styles = Style.active.where(["id BETWEEN ? and ?", page * 1000 + 1, (page + 1) * 1000]).order('id')
		@no_ads = true
		@no_bots = true
	end

	def stats
		@style = Style.find(params[:id])
		@page_title = @style.short_description + ' stats'
		raw_counts = StyleInstallCount.where(:style_id => params[:id])
		# group by date and source
		@counts = {}
		raw_counts.each do |rc|
			@counts[rc.date] = {} unless @counts.has_key?(rc.date)
			@counts[rc.date][rc.source] = rc.install_count
		end
	end

	def validate
		style = Style.find(params[:id])
		@page_title = "Validate"
		cp = style.code_possibilities
		# take out the -moz-docs, as the validator doesn't support it
		@codes = []
		cp.each do |a|
			p = a[0]
			c = a[1]
			sc = StyleCode.new
			sc.code = c
			sections = sc.parse_moz_docs
			err = Style.get_parse_error_for_code(c)
			@codes << [displayable_settings_param(p), sections.map {|s| s[:code]}.join("\n"), err]
		end
		@no_ads = true
		@no_bots = true
	end
	
	def reviewable
		ids = Style.connection.select_values('SELECT s.id FROM styles s JOIN ( SELECT StyleID, DateInserted, rating FROM  GDN_Discussion d WHERE d.rating != 0 and Closed = 0 ) d ON d.StyleID = s.id WHERE s.obsolete = 0 GROUP BY s.id HAVING GROUP_CONCAT(d.rating ORDER BY DateInserted DESC) LIKE "1,1%" ORDER BY s.id, DateInserted DESC;')
		if !params[:per_page].nil? and params[:per_page].to_i > 0 and params[:per_page].to_i <= 200
			per_page = params[:per_page].to_i
		else
			per_page = 100
		end
		if ids.empty?
			@styles = []
		else
			@styles = Style.paginate(:all, :conditions => "id IN (#{ids.join(',')})", :per_page => per_page, :order => 'popularity_score DESC', :page => params[:page])
		end
		@no_ads = true
		@no_bots = true
		@page_title = "Reviewable styles (#{@styles.empty? ? 0 : @styles.total_entries})"
		render :action => 'browse'
	end
	

protected

	def public_action?
		['show', 'show_redirect', 'install', 'search_url', 'search_text', 'search', 'browse_r', 'browse', 'graveyard', 'updated', 'js', 'opera_css', 'ie_css', 'chrome_json', 'proxomitron', 'by_user', 'expire_by_id', 'screenshotable', 'automation_page'].include?(action_name)
	end
	
	def admin_action?
		['admin_delete', 'admin_delete_save', 'bad_stuff', 'lotsa_screenshots', 'reviewable'].include?(action_name)
	end
	
	def verify_private_action(user_id)
		# any user can do these
		return true if ['new', 'create'].include?(action_name)
		if ['update', 'delete_save'].include?(action_name)
			style_id = params[:style][:id]
		elsif ['edit', 'delete', 'stats'].include?(action_name)
			style_id = params[:id]
		else
			return false
		end
		style = Style.find(style_id)
		return false if style.nil?
		return style.user_id == user_id
	end

	def get_option_params
		op = {}
		params.each do |k,v|
			if k.index("option-") == 0
				op[k[7, k.length]] = v
			end
		end
		if !flash[:settings].nil?
			flash[:settings].each do |k,v|
				if k.index("option-") == 0
					op[k[7, k.length]] = v
				end
			end
		end
		return op
	end

	def fix_search_url(params)
		fixed = false

		if params[:category] == 'all' and (params[:search_terms].nil? or params[:search_terms].empty?)
			params[:category] = nil
			fixed = true
		end

		if params[:search_terms] == 'all'
			params[:search_terms] = nil
			fixed = true
		end

		search_terms = params[:search_terms]
		search_terms.strip! if !search_terms.nil?
		keywords = []
		urls = []
		if !search_terms.nil?
			search_terms.split(' ').each do |term|
				# fix nginx/passenger's stripping of double slashes
				# look for protocol:/something
				missing_double_slash_match = /\A([a-z]+)\:\/([^\/])/.match(term)
				if !missing_double_slash_match.nil?
					term = term.sub(missing_double_slash_match[0], "#{missing_double_slash_match[1]}://#{missing_double_slash_match[2]}")
				end
				# look for things in the form of "google.com" or full urls
				possible_domain_parts = term.split('.')
				if (possible_domain_parts.length > 1 and !/[a-z]/i.match(possible_domain_parts[-1]).nil?) or term.include?('//')
					urls << term
				else
					keywords << term
				end
			end
			keywords = keywords - ['skin', 'theme', 'layout', 'style', 'for', 'the']
		end

		# includes a url - get the subcategory and show that
		if !urls.empty?
			subcategory = Style.get_subcategory_for_url(urls[0])
			params[:category] = subcategory
			params[:search_terms] = keywords.join(' ')
			fixed = true
		elsif keywords.size == 1 and (params[:category].nil? or params[:category] == 'all')
			# one keyword without a category - see if it matches a common subcategory name
			subcategory_styles = Style.active.where(:subcategory => keywords[0]).limit(10)
			if subcategory_styles.size == 10
				params[:category] = keywords[0]
				params[:search_terms] = nil
				fixed = true
			end
		end

		return fixed
	end
	
	def displayable_settings_param(p)
		s = []
		p.keys.sort.each do |k|
			so = StyleOption.find(k)
			# use the display name for dropdowns, otherwise the value
			if so.option_type == "dropdown"
				s << [so.name, StyleOptionValue.find(p[k]).display_name]
			else
				s << [so.name, p[k]]
			end
		end
		return s
	end
	
private

	def handle_change(new)
		@no_bots = true
		
		# some validations are happening outside of the activerecord. calling validation on an activerecord
		# clears out the errors, so we can't store them there. instead, we'll store them in a local and add
		# them when we're about to display
		non_ar_errors = []

		if new
			@style = Style.new
			@style["user_id"] = session[:user_id]
			now = DateTime.now
			@style["created"] = now
			@style["updated"] = now
			@style.style_code = StyleCode.new
		else
			@style = Style.includes([{:style_options => :style_option_values}, :screenshots]).find(params["style"]["id"])
			#only mark it as updated if the css changed
			if @style.style_code.code != params["style"]["css"]
				@style.updated = DateTime.now
			end
		end

		@style.short_description = params["style"]["short_description"]
		@style.long_description = params["style"]["long_description"]
		@style.additional_info = params["style"]["additional_info"]
		@style.pledgie_id = params["style"]["pledgie_id"]
		@style.style_code.code = params["style"]["css"]
		@style.screenshot_type_preference = params["style"]["screenshot_type_preference"]
		@style.screenshot_url_override = params["style"]["screenshot_url_override"]
		@style.license = params["style"]["license"]

		if @style.screenshot_type_preference == 'manual' && params["style"]["after_screenshot"].nil? && @style.after_screenshot_name.nil?
			non_ar_errors << ['primary screenshot', 'must be provided with the chosen option']
		end

		#check for problems with the screenshots before saving them
		if !params["style"]["after_screenshot"].nil?
			@style.validate_screenshot(params["style"]["after_screenshot"], 'after').each do |attr, msg|
				non_ar_errors << [attr, msg]
			end
		end
		#existing screenshots
		@style.screenshots.each do |screenshot|
			screenshot.description = params["screenshot_description_#{screenshot.id}"]
			non_ar_errors << ['screenshot', 'is missing a description'] if screenshot.description.nil? or screenshot.description.empty?
			data = params["screenshot_#{screenshot.id}"]
			if !data.nil?
				@style.validate_screenshot(data, nil).each do |attr, msg|
					non_ar_errors << [attr, msg]
				end
			end
		end
		#new screenshots
		additional_screenshots = []
		(1..5).each do |i|
			description = params["new_screenshot_description_#{i}"]
			data = params["new_screenshot_#{i}"]
			# did the user submit anything?
			if (!description.nil? and !description.empty?) or (!data.nil? and data.size > 0)
				@style.validate_screenshot(data, nil).each do |attr, msg|
					non_ar_errors << [attr, msg]
				end
				non_ar_errors << ['screenshot', 'is missing a description'] if description.nil? or description.empty?
				additional_screenshots << {:description => description, :data => data}
			end
		end

		# @new_style_options will be read by the edit page in case of a validation fail because setting 
		# @style.style_options saves immediately.
		@new_style_options = []
		if !params['style_options_ids'].nil?
			params['style_options_ids'].each do |style_option_id|
				so = StyleOption.new
				so.display_name = params["setting-display-name-#{style_option_id}"]
				so.name = params["setting-name-#{style_option_id}"]
				so.option_type = params["setting-type-#{style_option_id}"]
				so.ordinal = style_option_id
				if so.option_type == "dropdown" or so.option_type == "image"
					if !params["option-display-name-#{style_option_id}"].nil?
						(0..(params["option-display-name-#{style_option_id}"].size - 1)).each do |i|
							sov = StyleOptionValue.new
							sov.display_name = params["option-display-name-#{style_option_id}"][i]
							sov.value = params["option-value-#{style_option_id}"][i]
							sov.default = sov.display_name == params["option-default-#{style_option_id}"]
							sov.ordinal = i
							so.style_option_values << sov
						end
					end
				else
					sov = StyleOptionValue.new
					sov.display_name = 'placeholder'
					sov.value = params["option-default-#{style_option_id}"]
					sov.default = true
					sov.ordinal = 1
					so.style_option_values << sov
				end
				@new_style_options << so
			end
		end

		# let's also verify a name isn't reused. we can't rely on 
		# rails validations because they only work after the style
		# is saved
		style_option_used_names = []
		@new_style_options.each do |style_option|
			if style_option_used_names.include?(style_option.name)
				non_ar_errors << ["style options", "contain duplicate placeholder '#{style_option.name}'"]
			else
				style_option_used_names << style_option.name
			end
		end
		
		begin
		
			# db doesn't support transactions, so we can't use rails transactions.
			# when we set the options just below, they will attempt to save immediately,
			# which can result in the options being saved but the style itself not.
			# to try to prevent this, check validity first. we'll set the options on a temp
			# object for the code validator to use
			@style.tmp_style_options = @new_style_options

			@style.refresh_meta
			
			if (!@style.subcategory.nil? and $bad_content_subcategories.include?(@style.subcategory)) or !$tld_specific_bad_domains.index{|d| @style.style_code.code.include?(d)}.nil?
				@style.errors.add("Styles", "for adult sites are not allowed on userstyles.org.")
			end

			raise ActiveRecord::RecordInvalid.new(@style) if !@style.valid? or !non_ar_errors.empty?

			@style.tmp_style_options = nil
			@style.style_options.destroy_all
			@style.style_options = @new_style_options

			@style.save!
			@style.style_code.save!
			
		rescue ActiveRecord::RecordInvalid
			non_ar_errors.each do |attr, msg|
				@style.errors.add(attr, msg)
			end
			@header_include = "<script type='text/javascript' src='http://#{STATIC_DOMAIN}/javascripts/jscolor.js'></script>\n".html_safe
			if new
				@page_title = "New style"
			else
				@page_title = "Editing #{@style.short_description}"
			end
			render :action => 'edit'
			return
		end

		#update the screenshots now that we have an id
		if !params["style"]["after_screenshot"].nil?
			@style.save_screenshot(params["style"]["after_screenshot"], :after)
		elsif params["remove_after_screenshot"]
			@style.after_screenshot_name = nil
		end
		@style.screenshots.each do |screenshot|
			if params["remove_screenshot_#{screenshot.id}"]
				@style.delete_additional_screenshot(screenshot)
			else
				data = params["screenshot_#{screenshot.id}"]
				if !data.nil? and data.size > 0
					@style.change_additional_screenshot(screenshot, data)
				else
					screenshot.save!
				end
			end
		end
		additional_screenshots.each do |screenshot|
			@style.save_additional_screenshot(screenshot[:data], screenshot[:description])
		end
		@style.save!

		redirect_to @style.pretty_url
	end

end
