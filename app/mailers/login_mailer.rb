class LoginMailer < ApplicationMailer
  layout false
  default from: 'rachel@getsupportflow.net'
  attr_reader :login
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
