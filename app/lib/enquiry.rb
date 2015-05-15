class Enquiry
  include Mailboxable
  attr_reader :email, :message
  delegate :request, :customer, to: :message
  delegate :team, to: :mailbox
  
  def initialize(email=Griddler::Email.new)
    @email = email
    @message = Message.new content:email
  end
  
  def save
    return unless valid?
    message.customer = existing_customer || create_customer
    message.mailbox = mailbox
    message.request = create_request
    message.save!
    request.increment :messages_count
    
    Activity.new(request:request, owner:customer).enquiry message
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
    return if agent_enquiry?
    Customer.create email_address:from, team:team
  end
  
  def create_request
    return team.requests.create! if agent_enquiry?
    customer.requests.create!(team:team)
  end
  
  def agent_enquiry?
    team.agents.map(&:email_address).include?(from)
  end
end