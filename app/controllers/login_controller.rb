class LoginController < ApplicationController

	def index
		if !session[:user_id].nil?
			go_to_return_to
			return
		end
		@page_title = "Login"
		@no_bots = true
	end

	def check
		render :text => session[:user_id] ? 'logged in' : 'not logged in'
	end

	def forum
		redirect_to(:action => "index", :return_to => params["ReturnUrl"])
	end

	def login_as
		session[:user_id] = User.find(params[:id]).id
		redirect_to '/'
	end

	def authenticate_normal
		if params[:login] and params[:password] and user = User.authenticate(params[:login], params[:password])
			# Only validate if the user was previously valid. some people may have bad data and if we
			# validate them, they can't log in.
			user_was_valid = user.valid?
			session[:user_id] = user.id
			remember = params[:remember] == "true"
			if remember
				if user.token.nil?
					user.token = user.generate_login_token
				end
				cookies[:login] = { :value => user.token, :expires => 2.weeks.from_now}
			end
			user.ip = request.remote_ip()
			user.lost_password_key = nil
			user.save(:validate => user_was_valid)
			go_to_return_to
			return
		end
		@page_title = "Login"
		@login_failed = true
   	 	render :action => "index" 
	end

	def authenticate_openid
		session[:remember] = params[:remember] == "true"
		session[:return_to] = params[:return_to]
		openid = params['openid']
		begin
			start(openid, url_for(:controller => :login, :action => :authenticate_openid_complete));
		rescue Exception => e
			@message = e
			@page_title = 'OpenID log in failed'
			return
		end
	end

	def authenticate_openid_complete

		response = self.complete(params, url_for(:controller => :login, :action => :authenticate_openid_complete));
	    sreg = OpenID::SReg::Response.from_success_response(response)
	    ua = UserAuthenticator.where(:provider => 'openid').where(:provider_identifier => response.identity_url).first
	    user = nil
	    user = ua.user unless ua.nil?
		if user.nil?
			user = User.new
			user.login = nil
			user.password = nil
			user.ip = request.remote_ip()
			#user.openid_url = response.identity_url
			ua = UserAuthenticator.new
			ua.provider = 'openid'
			ua.provider_identifier = response.identity_url
			user.user_authenticators << ua
			user.email = sreg['email']
			begin
				user.name = sreg['nickname']
			rescue Exception => e
				session[:temp_login_details] = {:provider_identifier => response.identity_url, :email => sreg['email']}
				redirect_to(:action => 'name_required')
				return
			end
			if user.name.nil? or user.name.length == 0
				session[:temp_login_details] = {:provider_identifier => response.identity_url, :email => sreg['email']}
				redirect_to(:action => 'name_required')
				return
			end
			if user.save
				if session[:remember]
					if user.token.nil?
						user.token = user.generate_login_token
						user.save
					end
					cookies[:login] = { :value => user.token, :expires => 2.weeks.from_now}
				end
				session[:user_id] = user.id
				go_to_return_to()
			else
				session[:temp_login_details] = {:provider_identifier => response.identity_url, :email => sreg['email'], :name => sreg['nickname']}
				redirect_to(:action => 'name_conflict')
			end
			return
		end
		# The user may already be invalid, we don't want to prevent logging in. If they're invalid,
		# we can't tell if their new name and e-mail are good, so we won't update those.
		user_was_valid = user.valid?
		if user_was_valid
			# Leave user name and e-mail alone if the passed value is invalid
			
			original_name = user.name
			user.name = sreg['nickname']
			if !user.valid?
				user.name = original_name
			end
			
			original_email = user.email
			user.email = sreg['email']
			if !user.valid?
				user.email = original_email
			end
		end

		if session[:remember]
			if user.token.nil?
				user.token = user.generate_login_token
			end
			cookies[:login] = { :value => user.token, :expires => 2.weeks.from_now}
		end
		user.ip = request.remote_ip()
		user.save(:validate => user_was_valid)
		session[:user_id] = user.id
		go_to_return_to
	end

	def name_conflict
		@page_title = 'Display name conflict'
		@taken_name = session[:temp_login_details][:name]
	end

	def name_required
		@page_title = 'Display name required'
	end

	def resolve_name_conflict
		if session[:temp_login_details].nil?
			redirect_to :action => 'index'
			return
		end
		
		if params[:name] == nil or params[:name].empty?
			redirect_to(:action => 'name_required')
			return
		end
		
		@user = User.new
		@user.login = nil
		@user.password = nil
		@user.ip = request.remote_ip()
		
		@user[:email] = session[:temp_login_details][:email]
		ua = UserAuthenticator.new
		ua.provider = 'openid'
		ua.provider_identifier = session[:temp_login_details][:provider_identifier]
		@user.user_authenticators << ua
		
		@user.name = params[:name]
		
		if @user.save
			session[:temp_login_details] = nil
			session[:user_id] = @user.id
			go_to_return_to()
			return
		end
		@taken_name = params[:name]
		@page_title = 'Display name conflict'
		render :action => 'name_conflict'
	end

	def resolve_name_required
		if session[:temp_login_details].nil?
			redirect_to :action => 'index'
			return
		end

		if params[:name] == nil or params[:name].empty?
			redirect_to(:action => 'name_required')
			return
		end

		@user = User.new
		@user.login = nil
		@user.password = nil
		@user.ip = request.remote_ip()
		
		@user[:email] = session[:temp_login_details][:email]
		ua = UserAuthenticator.new
		ua.provider = 'openid'
		ua.provider_identifier = session[:temp_login_details][:provider_identifier]
		@user.user_authenticators << ua
		
		@user.name = params[:name]

		if @user.save
			session[:temp_login_details] = nil
			session[:user_id] = @user.id
			go_to_return_to()
			return
		end

		@taken_name = params[:name]
		@page_title = 'Display name conflict'
		render :action => 'name_conflict'
	end

	def policy
		@page_title = 'Privacy policy'
	end

	def lost_password
		@page_title = 'Lost password recovery'
	end

	def lost_password_start
		@page_title = 'Lost password recovery'
		user = User.where(:email => params[:email]).first
		if !user.nil?
			user_was_valid = user.valid?
			# login might be nil if they started with openid
			user.login = user.name if user.login.nil?
			user.create_lost_password_key
			user.save(:validate => user_was_valid)
			LostPasswordMailer.password_reset(user).deliver
		end
	end

	def lost_password_done
		user = User.where(:lost_password_key => params[:id]).first unless params[:id].nil?
		if !user.nil?
			user.lost_password_key = nil
			@login = user.login
			@password = (1..6).collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
			user.password = @password
			user.save!
			return
		end
		render :text => "Sorry, didn't work.", :layout => true
	end

	def single_sign_on
		if session[:user_id].nil?
			render :nothing => true
		else
			user = User.find(session[:user_id])
			name = user.name.gsub('"', '\"')
			email = user.email
			email = 'user' + user.id.to_s + '@userstyles.org' if email.nil?
			send_data "HyperFoo=Bar\nUniqueID=#{user.id}\nName=\"#{name}\"\nEmail=#{email}", :type => "text/plain", :disposition => "inline"
		end
	end


private

	def public_action?
		['index', 'check', 'forum', 'authenticate_normal', 'authenticate_openid', 'authenticate_openid_complete', 'name_conflict', 'name_required', 'resolve_name_conflict', 'resolve_name_required', 'policy', 'lost_password', 'lost_password_start', 'lost_password_done', 'single_sign_on'].include?(action_name)
	end
	
	def admin_action?
		['login_as'].include?(action_name)
	end
	
	def verify_private_action(user_id)
		false
	end

	def go_to_return_to
		return_to = session[:return_to]
		if return_to.nil?
			return_to = params[:return_to]
		end
		if return_to.nil?
			logger.info("No return to URL, going to user page")
			redirect_to(:controller => "users", :action => "show", :id => session[:user_id]) 
		else
			logger.info("Going to return to URL - " + return_to)
			session[:return_to] = nil
			redirect_to(return_to)
		end
	end
end
