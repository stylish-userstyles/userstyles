class LostPasswordMailer < ActionMailer::Base
	default :from => 'noreply@userstyles.org'

	def password_reset(user)
		mail(:to => user.email, :subject => 'userstyles.org password recovery')
		@key = user.lost_password_key
	end
end
