class LoginObserver < ActiveRecord::Observer
  def after_create(login)
    login.generate_token

    LoginMailer.login_email(login).deliver_later unless login.signup?
  end
end

Login.class_eval do
  def generate_token
    update token:auth_token
  end

  private

  def auth_token
    Base64.urlsafe_encode64 \
      [ id, SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz') ].
        join('-')
  end
end
