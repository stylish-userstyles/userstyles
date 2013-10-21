class LostPasswordMailer < ActionMailer::Base

  def password_reset(user)
    recipients user.email
    from 'noreply@userstyles.org'
    subject 'userstyles.org password recovery'
    body :key => user.lost_password_key
  end
end
