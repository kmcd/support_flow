class LoginMailer < ApplicationMailer
  layout false
  default from: 'rachel@getsupportflow.com'
  
  def login_email(session)
    session.generate_token
    @login_link = "http://getsupportflow.com/login/#{session.token}"
    
    mail to:session.email, subject:'Login'
  end
end
