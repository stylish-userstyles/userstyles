Userstyles::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  config.eager_load = true
  
  config.assets.compress = false
  config.assets.debug = true
  config.assets.prefix = "/dev-assets"

  # override domain set in config/initializers/session_store.rb
  config.session_store :cookie_store, :key => '_session_id', :domain => '.userstyles.local'
  
  # setting in an initializer isn't working to configure Rails.cache, so set here
  config.cache_store = :null_store
  #config.cache_store = :dalli_store, ['localhost:11211:10'], { :namespace => 'Userstyles', :expires_in => 1.hour, :compress => true }
end


DOMAIN = 'userstyles.local'
DOMAIN_PROTOCOL = 'http'
FORUM_DOMAIN = 'forum.userstyles.local'
STATIC_DOMAIN = 'http://userstyles.local'
UPDATE_DOMAIN = 'http://update.userstyles.local'
SCREENSHOT_DOMAIN = 'http://cdn.userstyles.org'
MD5_PATH = '/www/md5/'
COOKIE_DOMAIN = '.userstyles.local'

ActionMailer::Base.delivery_method = :test
