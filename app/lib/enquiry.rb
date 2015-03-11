class Enquiry
  attr_reader :email, :message
  delegate :request, :customer, to: :message
  
  def initialize(email=Griddler::Email.new)
    @email = email
    @message = Message.new content:email
  end
  
  def save
    return unless valid?
    message.customer = existing_customer || create_customer
    message.request = customer.requests.create!
    message.mailbox = mailbox
    message.save!
  end
  
  def valid?
    return if Command.new(email).valid?
    return if Reply.new(email).valid?
    mailbox.present?
  end
  
  def existing_customer
    Customer.
      joins(:messages).
      where(email_address:from).
      where('messages.mailbox_id' => mailbox.id).
      first
  end
  
  def create_customer
    Customer.create email_address:from
  end
  
  def mailbox
    @mailbox ||= Mailbox.where( email_address:to ).first
  end
  
  def to
    email.to.map {|_| _.fetch :email }
  end
  
  def from
    email.from[:email]
  end
end