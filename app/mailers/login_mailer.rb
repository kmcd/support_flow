class LoginMailer < ApplicationMailer
  layout false
  default from: 'rachel@getsupportflow.com'
  attr_reader :login
  helper_method :login_link
  
  def login_email(login)
    @login = login
    login.generate_token
    mail to:login.email, subject:'Login'
  end
  
  def signup_email(login)
    @login = login
    login.generate_token
    mail to:login.email, subject:'Welcome'
  end
end
