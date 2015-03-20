class Enquiry
  include Mailboxable
  attr_reader :email, :message
  delegate :request, :customer, to: :message
  
  def initialize(email=Griddler::Email.new)
    @email = email
    @message = Message.new content:email
  end
  
  def save
    return unless valid?
    message.customer = existing_customer || create_customer
    message.request = customer.requests.create!(team:mailbox.team)
    message.save!
    
    # TODO: Activity.new(request, agent).save
    # Should be able to set activity from request.new_record?
  end
  
  def valid?
    return if Command.new(email).valid?
    return if Reply.new(email).valid?
    mailbox.present?
  end
  
  private
  
  def existing_customer
    Customer.
      joins(:messages).
      where(email_address:from).
      where('messages.mailbox_id' => mailbox.id).
      first
  end
  
  def create_customer
    Customer.create email_address:from, team:mailbox.team
  end
end