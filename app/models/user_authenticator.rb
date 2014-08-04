class UserAuthenticator < ActiveRecord::Base

	belongs_to :user

	validates_inclusion_of :provider, :in => %w( openid google_oauth2 ), :allow_nil => false
	validates_length_of :provider, :minimum => 1

	validates_length_of :provider_identifier, :minimum => 1
	validates_uniqueness_of :provider_identifier, :allow_nil => false

	def pretty_provider
		self.class.pretty_provider(provider)
	end

	def self.pretty_provider(provider)
		Rails.application.config.available_auths[provider]
	end

end
