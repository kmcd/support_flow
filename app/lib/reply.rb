class Reply
  attr_reader :email
  SUBJECT_REGEX = /request#(\d+)/
  RECIPIENT_REGEX = /request\.(\d)+@getsupportflow/
  
  def initialize(email=Griddler::Email.new)
    @email = email
  end
  
  def valid?
    return if Command.new(email).valid?
    request_id.present?
  end
  
  def save
    return unless valid?
    message.request_id = request_id
    message.save!
  end
  
  private
  
  def request_id
    from_subject || from_recipients
  end
  
  def from_subject
    subject_request = SUBJECT_REGEX.match(email.subject)
    subject_request && subject_request[1]
  end
  
  def from_recipients
    recipient_request = recipients.find {|_| RECIPIENT_REGEX.match _ }
    recipient_request && RECIPIENT_REGEX.match(recipient_request)[1]
  end
end