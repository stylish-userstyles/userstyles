class LostPasswordMailer < ActionMailer::Base
	default :from => 'noreply@userstyles.org'

	def password_reset(user)
		@key = user.lost_password_key
		mail(:to => user.email, :subject => 'userstyles.org password recovery', :content_type => 'text/plain')
	end
end
