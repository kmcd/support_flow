class LoginMailer < ApplicationMailer
  attr_reader :login
  layout false
  default from: 'rachel@getsupportflow.net'
  helper_method :login_link

  def login_email(login)
    @login = login
    mail to:login.email, subject:'Login'
  end

  def signup_email(login)
    @login = login
    mail to:login.email, subject:'Welcome'
  end
end
