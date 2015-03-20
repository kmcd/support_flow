module Mailboxable
  def mailbox
    @mailbox ||= \
      request_mailbox || \
      addressed_to_mailbox || \
      request_address_mailbox
  end
  
  private
  
  def to
    email.to.map {|_| _.fetch :email }
  end
  
  def from
    email.from[:email]
  end
  
  def recipients
    [ email.to, email.cc ].flatten.map {|_| _.fetch :email }
  end
  
  def request_mailbox
    return unless request
    Mailbox.
      joins(:messages).
      where('messages.request_id' => request.id).
      first
  end
  
  def addressed_to_mailbox
    Mailbox.where( email_address:to ).first
  end
    
  # TODO: move to email router; i.e. request.736 -> mailbox.438
  def request_address_mailbox
    return unless request_id
    Request.find(request_id).messages.first
  end
  
  def request_id
    requests = recipients.grep /request\.\d+/
    return if requests.empty?
    
    requests.first.match(/request\.(\d+)/)[1]
  end
end
