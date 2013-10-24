class LoginController < ApplicationController
	layout "standard_layout"
#	after_filter OutputCompressionFilter

	#$store_dir = Pathname.new(Dir.tmpdir).join("openid-store")
	#$store = OpenID::FilesystemStore.new($store_dir)

  def index
		if session[:user]
			go_to_return_to
			return
		end
		@page_title = "Login"
		@no_bots = true
    # show login screen
  end

	def check
		render :text => session[:user] ? 'logged in' : 'not logged in'
	end

	def forum
		redirect_to(:action => "index", :return_to => params["ReturnUrl"])
	end

	def login_as
		if session[:user].nil? or session[:user].id != $admin_id
			render :text => "Access denied.", :layout => true
			return
		end
		session[:user] = User.find(params[:id])
		redirect_to '/'
	end

	def authenticate_normal
		if params[:login] and params[:password] and user = User.authenticate(params[:login], params[:password])
			session[:user] = user
			remember = params[:remember] == "true"
			if remember
				if user.token.nil?
					user.token = user.generate_login_token
				end
				cookies[:login] = { :value => user.token, :expires => 2.weeks.from_now}
			end
			user.ip = request.remote_ip()
			user.lost_password_key = nil
			user.save!
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
			user.email = sreg["email"]
			begin
				user.name = sreg["nickname"]
			rescue Exception => e
				session[:temp_user] = user
				redirect_to(:action => "name_required")
				return
			end
			if user.name.nil? or user.name.length == 0
				session[:temp_user] = user
				redirect_to(:action => "name_required")
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
				session[:user] = user
				go_to_return_to()
			else
				session[:temp_user] = user
				redirect_to(:action => "name_conflict")
			end
			return
		end
		original_name = user.name
		user.name = sreg["nickname"]
		user.email = sreg["email"]
		#the nickname might be in use
		if !user.valid?
			user.name = original_name
		end
		if session[:remember]
			if user.token.nil?
				user.token = user.generate_login_token
			end
			cookies[:login] = { :value => user.token, :expires => 2.weeks.from_now}
		end
		user.ip = request.remote_ip()
		user.save
		session[:user] = user
		go_to_return_to()
	end

	def name_conflict
		@page_title = "Display name conflict"
		@taken_name = session[:temp_user].name
	end

	def name_required
		@page_title = "Display name required"
	end

	def resolve_name_conflict
		@user = session[:temp_user]
		@user.name = params[:name]
		if @user.save
			session[:temp_user] = nil
			session[:user] = @user
			go_to_return_to()
		else
			@taken_name = session[:temp_user].name
			render :action => "name_conflict"
		end
		return
	end

	def resolve_name_required
		if params[:name] == nil
			redirect_to(:action => "name_required")
			return
		end
		@user = session[:temp_user]
		if @user.nil?
			redirect_to :action => 'index'
			return
		end
		@user.name = params[:name]
		if @user.save
			session[:temp_user] = nil
			session[:user] = @user
			go_to_return_to()
		else
			@taken_name = session[:temp_user].name
			render :action => "name_conflict"
		end
	end

	def policy
		@page_title = "Privacy policy"
	end

	def lost_password
		@page_title = "Lost password recovery"
	end

	def lost_password_start
		@page_title = 'Lost password recovery'
		user = User.where(:email => params[:email]).first
		if !user.nil?
			# login might be nil if they started with openid
			user.login = user.name if user.login.nil?
			user.create_lost_password_key
			user.save!
			LostPasswordMailer.password_reset(user).deliver
		end
	end

	def lost_password_done
		user = User.where(:lost_password_key => params[:id]).first
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
		if session[:user].nil?
			render :nothing => true
		else
			name = session[:user].name.gsub('"', '\"')
			email = session[:user].email
			email = 'user' + session[:user].id.to_s + '@userstyles.org' if email.nil?
			send_data "HyperFoo=Bar\nUniqueID=#{session[:user].id}\nName=\"#{name}\"\nEmail=#{email}", :type => "text/plain", :disposition => "inline"
		end
	end


private

	def go_to_return_to
		return_to = session[:return_to]
		if return_to.nil?
			return_to = params[:return_to]
		end
		if return_to.nil?
			logger.info("No return to URL, going to user page")
			redirect_to(:controller => "users", :action => "show", :id => session[:user].id) 
		else
			logger.info("Going to return to URL - " + return_to)
			session[:return_to] = nil
			redirect_to(return_to)
		end
	end
end
