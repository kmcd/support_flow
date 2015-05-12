class Authentication
  attr_reader :email_credentials
  
  def initialize(token)
    @email_credentials = credentials(token)
  end
  
  def valid?
    return unless tokens_match?
    return unless agent.present?
    (5.minutes.ago..0.minutes.ago).cover? session.updated_at
  end
  
  def session
    @session ||= Session.find email_credentials[:session_id]
  end
  
  def agent
    @agent ||= Agent.where(email_address:session.email).first
  end
  
  private
  
  # constant-time comparison algorithm to prevent timing attacks
  # https://github.com/plataformatec/devise/blob/master/lib/devise.rb#L473
  def tokens_match?
    return if session_token.blank? || email_token.blank?
    return unless session_token.bytesize == email_token.bytesize
    
    l = session_token.unpack "C#{session_token.bytesize}"
    res = 0
    email_token.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
  
  def credentials(token)
    decoded = Base64.urlsafe_decode64 token
    session_id = decoded[/^\d+/]
    token = decoded.gsub /^\d+\-/, ''
    
    { session_id:session_id, token:token }
  end
  
  def session_token
    credentials(session.token)[:token]
  end
  
  def email_token
    email_credentials[:token]
  end
end
