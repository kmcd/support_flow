class LoginMailer < ApplicationMailer
  layout false
  default from: 'rachel@getsupportflow.net'
  attr_reader :login
  helper_method :login_link

  def login_email(login)
    @login = login
    mail to:login.email_address, subject:'Login'
  end

  def signup_email(login)
    @login = login
    mail to:login.email_address, subject:'Welcome'
  end
end
