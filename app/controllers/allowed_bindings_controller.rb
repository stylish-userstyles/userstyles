class AllowedBindingsController < ApplicationController

	def index
		@allowed_bindings = AllowedBinding.all
	end
	
private
	def public_action?
		false
	end
	
	def admin_action?
		true
	end
	
	def verify_private_action(user_id)
		false
	end
end
