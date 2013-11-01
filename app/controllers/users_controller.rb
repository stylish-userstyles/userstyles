require 'will_paginate'

class UsersController < ApplicationController
	helper :styles
	helper :users

	def show
		@user_displayed = User.find(params[:id])
		if @user_displayed.id == session[:user_id]
			@styles = Style.where(:user_id => @user_displayed.id).order('obsolete, short_description')
			# prevent 2n loads
			@style_forum_stats = @user_displayed.style_forum_stats
		else
			if !params[:per_page].nil? and params[:per_page].to_i > 0 and params[:per_page].to_i <= 200
				per_page = params[:per_page].to_i
			else
				per_page = 10
			end
			@styles = Style.active.where(:user_id => @user_displayed.id).order('short_description').paginate({:per_page => per_page, :page => params[:page]})
			@no_ads = @styles.empty?
		end

		respond_to do |format|
			format.html {
				@page_title = @user_displayed.name
				@feeds = []
				@feeds << {:title => "Styles by this user", :href => "#{@user_displayed.id}/styles.rss", :type => "application/rss+xml"}
				@feeds << {:title => "Styles by this user", :href => "#{@user_displayed.id}/styles.atom", :type => "application/atom+xml"}
			}
			format.json {
				render :text => @styles.to_json
			}
			format.jsonp {
				callback = params[:callback]
				callback = 'handleUserstylesData' if callback.nil? or /^[$A-Za-z_][0-9A-Za-z_\.]*$/.match(callback).nil?
				render :text => callback + '(' + @styles.to_json + ');'
			}
		end
	end

	def show_by_forum_id
		user = User.get_user_for_forum_id(params[:id])
		if user.nil?
			render :nothing => true, :status => 404
		else
			redirect_to :controller => 'users', :action => 'show', :id => user
		end
	end

	def show_by_name
		user = User.where(:name => params[:id]).first
		if user.nil?
			render :nothing => true, :status => 404
		else
			redirect_to user
		end
	end

	def comments
		render :nothing => true, :status => 410
	end

	def comments_on
		render :nothing => true, :status => 410
	end

	def new
		#shouldn't this be handled by the routing?
		if request.post?
			create
			return
		end
		@page_title = "Register"
		@user = User.new
	end

	def create
		@page_title = "Register"
		@user = User.new
		@user.update_attributes!(user_params)
		@user.name = @user.login if @user.name.nil? or @user.name = ''
		@user.ip = request.remote_ip()
		@return_to = params[:return_to]
		if @return_to.nil?
			@return_to = session[:return_to]
		end
		if @user.password.length <= 3
			@user.errors.add('password', 'must be at least 3 characters.')
			render :action => "new"
			return
		end
		begin
			@user.save!
		rescue ActiveRecord::RecordInvalid
			render :action => "new"
			return
		end
		session[:user_id] = @user.id
		if @return_to.nil?
			redirect_to(:action => "show", :id => @user.id)
		else
			session[:return_to] = nil
			redirect_to(@return_to)
		end
	end

	def edit
		@user = User.find(params[:id])
		@page_title = "Editing " + @user.name
	end

	def update
		@user = User.find(params[:id])
		@user.update_attributes!(user_params)
		if !@user.save
			render(:action => :edit)
			return
		end
		redirect_to user_url(@user)
	end
	
	def edit_login_methods
		@user = User.find(params[:id])
		@page_title = "Change login methods"
	end

	def index
		render :nothing => true, :status => 410
	end

	def edit_password
		@user = User.find(params[:id])
		@page_title = "Change password"
	end

	def update_password
		@page_title = "Change password"
		@user = User.find(params[:id])
		if params[:user].nil?
			@user.login = nil
		else
			@user.login = params[:user][:login] 
		end
		@user.errors.add(:login, "was not provided") if @user.login.nil? or @user.login.empty?
		@user.errors.add(:new_password, "was not provided") if params[:password].nil? or params[:password].empty?
		if !@user.errors.empty?
			render :action => 'edit_login_methods'
			return
		end
		@user.password = params[:password]
		@user.password_confirmation = params[:password_confirmation]
		if @user.save
			redirect_to(:action => "edit_login_methods", :id => @user.id, :password_updated => true)
			return
		else
			render :action => 'edit_login_methods'
		end
	end
	
	def remove_password
		@page_title = "Change password"
		@user = User.find(params[:id])
		if !@user.has_spare_login_methods
			render :action => 'edit_login_methods'
			return
		end
		@user.login = nil
		@user.hashed_password = nil
		@user.lost_password_key = nil
		@user.save!
		redirect_to(:action => "edit_login_methods", :id => @user.id, :password_removed => true)
	end

	def add_authenticator
		@user = User.find(params[:id].to_i)
		if params[:provider_identifier] == nil or params[:provider_identifier].length == 0
			@user.errors.add(:provider_identifier, "cannot be blank")
			@page_title = "Migrate account to OpenID"
			render :action => 'edit_login_methods'
			return
		end
		
		begin
			self.start(params[:provider_identifier], url_for(:action => :add_authenticator_complete, :id => @user.id));
		rescue OpenID::OpenIDError => e
			@message = e
			render :action => 'edit_login_methods'
			return
		end
	end

	def add_authenticator_complete
		@user = User.find(params[:id])
		if @user == nil
			render :action => 'edit_login_methods'
			return
		end

		begin
			response = self.complete(params, url_for(:controller => :login, :action => :add_authenticator_complete));
		rescue Exception => e
			@message = e
			render :action => 'edit_login_methods'
			return
		end
		sreg = OpenID::SReg::Response.from_success_response(response)

		existing_ua = UserAuthenticator.where(:provider_identifier => response.identity_url).where(:provider => 'openid')
		user_with_this_openid = existing_ua.user unless existing_ua.nil?
		if !user_with_this_openid.nil?
			if user_with_this_openid.id == @user.id
				@message = 'This OpenID is already set on your account.'
				render :action => 'edit_login_methods'
				return			
			end
			@message = "Provided OpenID already in use by user '#{user_with_this_openid.name}'."
			render :action => 'edit_login_methods'
			return
		end

		@ua = UserAuthenticator.new
		@ua.provider = 'openid'
		@ua.provider_identifier = response.identity_url
		@ua.user = @user
		#@user.user_authenticators << @ua
		
		#@user.email = sreg["email"]
		begin
			@ua.save!
			#@user.save!
		rescue ActiveRecord::RecordInvalid
			@message = 'Migration failed.'
			@user.reload
			render :action => 'edit_login_methods'
			return
		end

		redirect_to(:controller => "users", :action => 'edit_login_methods', :id => @user.id, :authenticator_added => true)
	end

	def remove_authenticator
		@user = User.find(params[:id])
		if @user == nil
			@message = 'OpenID remove failed - user not found.'
			render :action => 'edit_login_methods'
			return
		end
		
		existing_ua = UserAuthenticator.where(:provider_identifier => params[:provider_identifier]).where(:provider => 'openid').first
		if existing_ua.nil? or existing_ua.user_id != @user.id
			@message = 'OpenID remove failed - could not find authenticator.'
			render :action => 'edit_login_methods'
			return
		end
		
		if !@user.has_spare_login_methods
			@message = "OpenID remove failed - you'd have no way to log in!"
			render :action => 'edit_login_methods'
			return
		end
		
		existing_ua.delete
		
		redirect_to(:controller => "users", :action => 'edit_login_methods', :id => @user.id, :authenticator_removed => true)
	end

	def stats
		render :nothing => true, :status => 410
	end

	def comments_redirect
		render :nothing => true, :status => 410
	end

	def comments_on_redirect
		render :nothing => true, :status => 410
	end

  protected

	def public_action?
		['show', 'show_by_forum_id', 'show_by_name', 'comments', 'comments_on', 'new', 'create', 'index', 'stats', 'comments_redirect', 'comments_on_redirect'].include?(action_name)
	end

	def admin_action?
		return false
	end

	def verify_private_action(user_id)
		return user_id == params[:id].to_i
	end

private

	def user_params
		params.permit(:login, :email, :paypal_email, :show_email, :homepage, :about, :license)
	end

end
