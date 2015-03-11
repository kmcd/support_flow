class Reply
  SUBJECT_REGEX = /request#(\d+)/
  RECIPIENT_REGEX = /request\.(\d)+@getsupportflow/
  include Messageable
  
  def valid?
    request_id.present? && valid_agent?
  end
  
  def save
    return unless valid?
    message.request_id = request_id
    message.save!
  end
  
  def request_id
    from_subject || from_recipients
  end
  
  private
  
  def valid_agent?
    message.mailbox.team.agents.where(email_address:from).any?
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