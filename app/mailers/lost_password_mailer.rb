class LostPasswordMailer < ActionMailer::Base
	default :from => 'noreply@userstyles.org'

	def password_reset(users)
		@users = users
		# all these users will have the same e-mail
		mail(:to => users.first.email, :subject => 'userstyles.org password recovery', :content_type => 'text/plain')
	end
end
