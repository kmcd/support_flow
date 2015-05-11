class LoginMailer < ApplicationMailer
  layout false
  default from: 'rachel@getsupportflow.com'
  attr_reader :session
  helper_method :login_link
  attr_reader :session
  
  def login_email(session)
    @session = session
    session.generate_token
    
    mail to:session.email, subject:'Login'
  end
  
  def login_link
    session_url(session.token, host:host)
  end
  
  private
  
  def host
    return 'getsupportflow.com' if Rails.env.production?
    return 'localhost:3000'     if Rails.env.development?
    'test.host'
  end
end
