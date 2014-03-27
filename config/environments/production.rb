Userstyles::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  config.log_level = :warn

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  config.assets.compress = true
  config.assets.js_compressor  = :uglifier
  config.assets.css_compressor = :yui
  config.assets.compile = false
  config.assets.digest = true
  config.action_controller.asset_host = "https://723d.https.cdn.softlayer.net/80723D/static.userstyles.org"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  config.eager_load = false
  
  # setting in an initializer isn't working to configure Rails.cache, so set here
  config.cache_store = :dalli_store, ['localhost:11211:10'], { :namespace => 'Userstyles', :expires_in => 1.hour, :compress => true }
end

DOMAIN = 'userstyles.org'
DOMAIN_PROTOCOL = 'https'
FORUM_DOMAIN = 'forum.userstyles.org'
STATIC_DOMAIN = 'https://723d.https.cdn.softlayer.net/80723D/static.userstyles.org'
UPDATE_DOMAIN = 'https://update.userstyles.org'
SCREENSHOT_DOMAIN = 'https://723d.https.cdn.softlayer.net/80723D/static.userstyles.org'
MD5_PATH = '/home/www/update/'
COOKIE_DOMAIN = '.userstyles.org'

ActionMailer::Base.delivery_method = :sendmail

