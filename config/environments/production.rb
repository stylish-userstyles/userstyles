# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger        = SyslogLogger.new


# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

ActionMailer::Base.delivery_method = :sendmail

CSS_PRE_CACHE = false
COOKIE_DOMAIN = '.userstyles.org'
USE_ALL_LOCAL = false

#config.action_controller.session[:domain] = '.userstyles.org'
config.action_controller.session = {:domain => '.userstyles.org'}
