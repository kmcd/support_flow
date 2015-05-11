class Authentication
  attr_reader :session, :email_token
  
  def initialize(token)
    @token = token
    
    @session = Session.find(credentials[:session_id]).tap &:token
    @email_token = credentials[:token]
  end
  
  def valid?
    return unless tokens_match?
    session.updated_at <= 5.mins.ago
    # TODO: use ActiveModel errors for view
  end
  
  private
  
  # constant-time comparison algorithm to prevent timing attacks
  # https://github.com/plataformatec/devise/blob/master/lib/devise.rb#L473
  def tokens_match?
    return if session.token.blank? || email_token.blank?
    return if session.token.bytesize != email_token.bytesize
    
    l = unpack "C#{session.token.bytesize}"
    res = 0
    email_token.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
  
  def credentials
    decoded = Base64.urlsafe_decode64 @token
    session_id = decoded[/^\d+/]
    token = decoded.gsub /^\d+\-/, ''
    
    { session_id:session_id, token:token }
  end
end
