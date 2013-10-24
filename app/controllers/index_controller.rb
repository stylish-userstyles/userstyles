require 'action_cache'

class IndexController < ApplicationController
	layout "standard_layout"
#	after_filter OutputCompressionFilter
	helper 'styles'
	caches_action :index, :firstrun, :expires_in => 5.minutes

	def index
		@new = Style.newly_added(nil, 10)
		@best = Style.top_styles(10, 100)
		@page_title = "Restyle the web with Stylish!"
		@meta_description = "Customize your favorite web sites with Stylish and user styles." 
		@header_include = "<meta name=\"keywords\" content=\"userstyles user styles skin theme stylish firefox chrome extension css userchrome usercontent addon customize\">".html_safe
		@show_site_wide_ads = false
	end

	def rescue_404
		@page_title = "404'd!"
		render :status => "404", :layout => true
	end

	def firstrun
		@best = Style.top_styles(3, 25)
		render :layout => false
	end

	def contact
		@page_title = "Contact the admin"
	end

end
