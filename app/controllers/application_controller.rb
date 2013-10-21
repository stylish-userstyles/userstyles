require "openid"
require 'openid/extensions/sreg'
require 'openid/store/filesystem'

class ApplicationController < ActionController::Base
	include ApplicationHelper
	before_filter :refresh_user_from_cookie
	before_filter :authenticate
	before_filter :refresh_flags

	protected
		def secure?
			false
		end

		# persistent login
		def refresh_user_from_cookie
			return if cookies[:login].nil?
			return unless session[:user].nil?
	    	user = User.find_by_token(cookies[:login])
		    if !user.nil?
				#restart the clock
				cookies[:login] = { :value => cookies[:login], :expires => 2.weeks.from_now}
				session[:user] = user
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
		redirect_to oidreq.redirect_url(url_for(:controller => :index), return_url)
	end

	def complete(params, return_url)
		parameters = params.reject{|k,v|request.path_parameters[k]}
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
			dir = Pathname.new(RAILS_ROOT).join('db').join('cstore')
			store = OpenID::Store::Filesystem.new(dir)
			@consumer = OpenID::Consumer.new(session, store)
		end
		return @consumer
	end

	$sorts_map = {'name' => 'short_description', 'total_installs' => 'total_install_count', 'installs_this_week' => 'weekly_install_count', 'created_date' => 'created', 'updated_date' => 'updated', 'popularity' => 'popularity_score', 'relevance' => '@relevance, popularity_score'}

	$new_sorts_map = {'name' => 'name DIR', 'total_installs' => 'total_install_count DIR', 'installs_this_week' => 'weekly_install_count DIR', 'created_date' => 'created DIR', 'updated_date' => 'updated DIR', 'popularity' => 'popularity DIR', 'relevance' => '@relevance DIR, popularity DIR'}


	private
		def authenticate
			if secure? && session[:user].nil?
				session[:return_to] = request.request_uri
				redirect_to :controller => "login" 
				return false
			end
		end

		def refresh_flags
			# accessing the session will load it if it doesn't exist
			return if cookies[:_session_id].nil?
			return if session[:user].nil?
			#setting something in the cookie hash will send updated cookies regardless of whether anything's changed, so make sure we only set if we need to
			cookies[:user_id] = {:value => session[:user].id.to_s} if cookies[:user_id] != session[:user].id.to_s
		end

end
