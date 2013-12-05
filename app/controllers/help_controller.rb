class HelpController < ApplicationController

	def index
		@page_title = "Help"
	end

	def stylish
		@page_title = 'Using Stylish'
	end

	def stylish_firefox
		@page_title = 'Using Stylish for Firefox'
	end

	def stylish_chrome
		@page_title = 'Using Stylish for Chrome'
	end

	def userstylesorg
		@page_title = 'Using userstyles.org'
	end

	def coding
		@page_title = 'Posting user styles'
	end

	def other
		@page_title = 'Other info'
	end

	def db
		@page_title = 'Fixing a corrupted database in Firefox'
	end

	def db_chrome
		@page_title = 'Fixing a corrupted database in Chrome'
	end

	def widget
		@page_title = 'Userstyles.org widget'
	end

	def widget_details
		@page_title = 'Userstyles.org widget details'
	end
	
	def bundle
		@page_title = 'Bundled software'
		@no_ads = true
	end
	
private
	def public_action?
		true
	end
	
	def admin_action?
		false
	end
	
	def verify_private_action(user_id)
		false
	end
end
