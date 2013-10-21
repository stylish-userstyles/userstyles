# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes     = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils        = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
ActionController::Base.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
ActionMailer::Base.delivery_method = :test

CSS_PRE_CACHE = false
COOKIE_DOMAIN = '0.0.0.0'
USE_ALL_LOCAL = true
