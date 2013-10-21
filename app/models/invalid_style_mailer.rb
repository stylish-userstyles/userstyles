class InvalidStyleMailer < ActionMailer::Base

  def url_format(email, styles)
    #recipients 'jason.barnabe@gmail.com'
    recipients email
    from 'noreply@userstyles.org'
    subject 'userstyles.org style validation'
    body :styles => styles
  end

  def url_unresolved(email, styles)
    #recipients 'jason.barnabe@gmail.com'
    recipients email
    from 'noreply@userstyles.org'
    subject 'userstyles.org style validation'
    body :styles => styles
  end
end
