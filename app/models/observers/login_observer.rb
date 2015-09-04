class LoginObserver < ActiveRecord::Observer
  def after_create(login)
    login.generate_token
    login.dispatch_email
  end
end

Login.class_eval do
  def generate_token
    update token:auth_token
  end

  def dispatch_email
    return if signup?

    LoginMailer.login_email(self).deliver_later
  end

  private

  def auth_token
    Base64.urlsafe_encode64 \
      [ id, SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz') ].
        join('-')
  end
end
