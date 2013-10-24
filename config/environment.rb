# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Userstyles::Application.initialize!

Mime::Type.register('text/plain','md5');
Mime::Type.register('text/javascript','jsonp');
ActiveRecord::Base.include_root_in_json = false
