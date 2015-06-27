class IndexController < ApplicationController
	helper 'styles'

	def index
		@new = Style.newly_added(nil, 10)
		@best = Style.top_styles(10, 100)
		@page_title = "Restyle the web with Stylish!"
		@meta_description = "Customize your favorite web sites with Stylish and user styles." 
		@show_site_wide_ads = false
	end

	def rescue_404
		@page_title = "404'd!"
		@no_ads = true
		@no_bots = true
		logger.warn "Request for #{request.original_url} resulted in 404."
		render :status => '404', :layout => true, :formats => [:html]
	end

	def firstrun
		@best = Style.top_styles(3, 25)
		render :layout => false
	end

	def contact
		@page_title = "Contact the admin"
	end
	
	def admin_debug
		render :layout => false
	end

private

	def public_action?
		action_name != 'admin_debug'
	end
	
	def admin_action?
		action_name == 'admin_debug'
	end
	
	def verify_private_action(user_id)
		false
	end

end
