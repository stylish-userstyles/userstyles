# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way

RAILS_ENV = 'development'

#ENV['GEM_PATH'] = '/var/lib/gems/1.8'
ENV['GEM_PATH'] = '/home/jason/.rvm/gems/ruby-1.8.7-p374/gems/'


#RAILS_GEM_VERSION = '2.0.1' unless defined? RAILS_GEM_VERSION
RAILS_GEM_VERSION = '2.3.15' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# support for newer rubygems
if Gem::VERSION >= "1.3.6" 
    module Rails
        class GemDependency
            def requirement
                r = super
                (r == Gem::Requirement.default) ? nil : r
            end
        end
    end
end


Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
   config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

  # See Rails::Configuration for more options

	config.action_controller.session = {:domain => '.userstyles.local'}

	config.gem(
		'thinking-sphinx', :version => '1.4.14'
	)

	config.gem 'ts-delayed-delta',
		:lib     => 'thinking_sphinx/deltas/delayed_delta',
		:version => '1.1.1'

end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end


DOMAIN = "userstyles.local"
FORUM_DOMAIN = "forum.userstyles.local"
#STATIC_DOMAIN = "static.userstyles.org"
#STATIC_DOMAIN = "cdn.userstyles.org"
STATIC_DOMAIN = "userstyles.local:3000"
UPDATE_DOMAIN = "update.userstyles.org"
MD5_PATH = '/home/jason/md5test/'

Mime::Type.register('text/plain','md5');
Mime::Type.register('text/javascript','jsonp');
ActiveRecord::Base.include_root_in_json = false

# https://groups.google.com/forum/#!topic/rubyonrails-security/61bkgvnSGTQ/discussion
ActionController::Base.param_parsers.delete(Mime::XML) 
