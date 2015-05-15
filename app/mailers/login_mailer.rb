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
  
  def login_link
    login_url(login.token, host:host)
  end
  
  private
  
  def host
    return 'getsupportflow.com' if Rails.env.production?
    return 'localhost:3000'     if Rails.env.development?
    'test.host'
  end
end
