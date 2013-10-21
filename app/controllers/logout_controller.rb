class LogoutController < ApplicationController

	def index
		if not session[:user].nil?
			if not session[:user].token.nil?
				session[:user].token = nil
			end
			session[:user].save
		end
		reset_session
		cookies.delete(:login)
		cookies.delete(:session_id)
		cookies.delete(:user_id)
		flash["alert"] = "Logged out" 
		redirect_to "/"
	end
end
