require 'openid'
require 'openid/extensions/sreg'
require 'openid/store/filesystem'

class ApplicationController < ActionController::Base

	layout 'standard_layout'

	before_action :refresh_user_from_cookie
	before_action :authenticate

protected

	# persistent login
	def refresh_user_from_cookie
		return if cookies[:login].nil?
		return unless session[:user_id].nil?
		user = User.where(:token => cookies[:login]).first
		if !user.nil?
			sign_in(user)
			#restart the clock
			cookies[:login] = { :value => cookies[:login], :expires => 2.weeks.from_now, :domain => COOKIE_DOMAIN}
		end
	end

	def start(open_id, return_url)
		if (open_id.nil? or open_id.length == 0)
				raise Exception.new, 'No OpenID provided.'
		end
		oidreq = consumer.begin(open_id)
		sregreq = OpenID::SReg::Request.new
		# required fields
		sregreq.request_fields(['nickname'], true)
		# optional fields
		sregreq.request_fields(['email'], false)
		oidreq.add_extension(sregreq)
		# Google will return a different identity URL depending on the server in the first parameter.
		# It also won't allow the server in the first parameter to not match the URL in the second.
		# This means that this isn't going to work right in dev for Google - it will look like a new user.
		redirect_to oidreq.redirect_url(url_for(:controller => :index), return_url)
	end

	def complete(params, return_url)
		parameters = params.reject{|k,v|request.path_parameters[k]}.reject{|k,v| k == 'action' || k == 'controller' || k == 'id'}
		oidresp = consumer.complete(parameters, request.url)
		case oidresp.status
		when OpenID::Consumer::FAILURE
				if oidresp.display_identifier
						raise Exception.new, ("Verification of #{oidresp.display_identifier}"\
							 " failed: #{oidresp.message}")
				end
				raise Exception.new, "Verification failed: #{oidresp.message}"
		when OpenID::Consumer::SUCCESS
				return oidresp
		when OpenID::Consumer::SETUP_NEEDED
				raise Exception.new, "Immediate request failed - Setup Needed"
		when OpenID::Consumer::CANCEL
				raise Exception.new, "OpenID transaction cancelled."
		else
		end
	end

	def consumer
		if @consumer.nil?
				dir = Pathname.new(::Rails.root.to_s).join('db').join('cstore')
				store = OpenID::Store::Filesystem.new(dir)
				@consumer = OpenID::Consumer.new(session, store)
		end
		return @consumer
	end

	$sorts_map = {'name' => 'short_description', 'total_installs' => 'total_install_count', 'installs_this_week' => 'weekly_install_count', 'created_date' => 'created', 'updated_date' => 'updated', 'popularity' => 'popularity_score', 'relevance' => 'myweight, popularity_score'}

	$new_sorts_map = {'name' => 'name DIR', 'total_installs' => 'total_install_count DIR', 'installs_this_week' => 'weekly_install_count DIR', 'created_date' => 'created DIR', 'updated_date' => 'updated DIR', 'popularity' => 'popularity DIR', 'relevance' => 'myweight DIR, popularity DIR'}

	def handle_access_denied
		logger.warn "User from '#{request.remote_ip}' tried to '#{request.url}' and was denied. " +
			(!session.nil? and !session[:user_id].nil? ? "User ID is #{session[:user_id]}. " : "User is not logged in. ") +
			(params.to_s.length < 500 ? "Parameters are #{params}." : "Parameters are #{params.to_s.length} bytes long.")
		render :text => 'Access denied.', :status => 403, :layout => true
	end

	# Is the user a jerk?
	helper_method :jerk_user
	def jerk_user
		return false if !Userstyles::Application.config.respond_to?('jerk_ips')
		return Userstyles::Application.config.jerk_ips.include?(request.ip)
	end

	def fake_style(style)
		style.short_description = Faker::Internet.domain_name + "  " + Faker::Lorem.words(4).join(' ')
		style.long_description = Faker::Lorem.paragraphs(3).join("\n\n")
		return style
	end

	def sign_in(user)
		if user.banned
			flash[:alert] = 'You have been banned.'
		else
			session[:user_id] = user.id
		end
	end

private

	# User authentication. Controllers are expected to define the following methods:
	#   public_action? : return true if the current action is public (does not require login)
	#   admin_action? : return true if the current action is for admins only
	#   verify_private_action(user_id): return true if the passed user is allowed to perform the current
	#     private action. Don't worry about special 
	#     cases for admin.
	def authenticate
		# public stuff? allow
		return if public_action?
		
		# not logged in? redirect to login
		if session.nil? or session[:user_id].nil?
			# won't be able to complete anything other than GETs
			if request.get?
				redirect_to :controller => "login", :return_to => request.fullpath 
			else
				redirect_to :controller => "login"
			end
			return
		end

		user = User.find(session[:user_id])
		if user.banned
			flash[:alert] = 'You have been banned.'
			session[:user_id] = nil
			redirect_to '/'
			return
		end

		# admin only stuff
		if admin_action?
			handle_access_denied unless verify_admin_action
			return
		end

		# regular user stuff
		if !verify_private_action(session[:user_id]) and !verify_admin_action
			handle_access_denied
			return
		end
	end
	
	def verify_admin_action
		return session[:user_id] == 1
	end

	protect_from_forgery
end
