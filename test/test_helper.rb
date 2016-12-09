ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
	def get_style_template
		return Style.new(
			:short_description => 'Style name',
			:long_description => 'Style description',
			:user => User.find(1),
			:style_code => StyleCode.new
		)
	end
	
	def get_valid_style
		s = Style.new(
			:short_description => 'Style name',
			:long_description => 'Style description',
			:user => User.find(1),
			:created => DateTime.now,
			:updated => DateTime.now
		)
		s.build_style_code(code: '*{color:blue}')
		return s
	end
end
