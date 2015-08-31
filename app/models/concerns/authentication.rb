class Authentication
  attr_reader :email_credentials

  def initialize(token)
    @email_credentials = credentials token
  end

  def valid?
    return unless tokens_match?
    return unless agent.present?

    (5.minutes.ago..0.minutes.ago).cover? login.updated_at
  end

  def login
    @login ||= Login.find email_credentials[:login_id]
  end

  def agent
    @agent ||= Agent.where(email_address:login.email_address).first
  end

  private

  # constant-time comparison algorithm to prevent timing attacks
  # https://github.com/plataformatec/devise/blob/master/lib/devise.rb#L473
  def tokens_match?
    return if email_credentials.blank?
    return if login_token.blank?
    return if email_token.blank?

    return unless login_token.bytesize == email_token.bytesize

    l = login_token.unpack "C#{login_token.bytesize}"
    res = 0
    email_token.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end

  def credentials(token)
    return unless token.present?

    decoded = Base64.urlsafe_decode64 token
    login_id = decoded[/^\d+/]
    token = decoded.gsub /^\d+\-/, ''

    { login_id:login_id, token:token }
  end

  def login_token
    credentials(login.token)[:token]
  end

  def email_token
    email_credentials[:token]
  end
end
