class Enquiry
  attr_reader :message
  
  def initialize(message)
    @message = message
  end
  
  def save
    return if reply?
    message.customer = customer
    message.create_request customer:customer
    message.save!
  end
  
  private
  
  def email
    message.content # TODO: delegate email to message
  end
  
  def to
    email.to.map {|_| _.fetch :email }
  end
  
  def from
    email.from.fetch :email
  end
  
  def cc
    email.cc.map {|_| _.fetch :email }
  end
  
  def recipients
    [to, cc].flatten
  end
  
  def reply?
    return true if email.subject =~ /request#\d+/
    recipients.any? {|_| _ =~ /request\.\d+@getsupportflow/ }
  end
  
  def customer
    existing_customer || create_customer
  end
  
  def existing_customer
    Customer.
      joins(:messages).
      where(email_address:from).
      where('messages.mailbox_id' => message.mailbox_id).
      first
  end
  
  def create_customer
    Customer.create email_address:from
  end
end