class LogoutController < ApplicationController

	def index
		if !session[:user_id].nil?
			user = User.find(session[:user_id])
			if !user.token.nil?
				user.token = nil
				user.save(:validate => false)
			end
		end
		reset_session
		cookies.delete(:login)
		cookies.delete(:session_id)
		# log out of vanilla too
		cookies.delete('Vanilla', :domain => COOKIE_DOMAIN)
		cookies.delete('Vanilla-Volatile', :domain => COOKIE_DOMAIN)
		redirect_to '/'
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
