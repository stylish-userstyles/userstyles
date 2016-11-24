class MiscController < ApplicationController

	def copyright
		@page_title = "Stylish - Copyright Notice"
	end

	def terms
		@page_title = "Stylish - Terms of Use"
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
