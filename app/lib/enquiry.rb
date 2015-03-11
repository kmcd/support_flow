class Enquiry
  include Messageable
  
  def save
    return if reply?
    message.customer = customer
    message.create_request customer:customer
    message.save!
  end
  
  private
  
  def reply?
    Reply.new(message).request_id.present?
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