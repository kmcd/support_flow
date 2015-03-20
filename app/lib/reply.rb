class Reply
  include Mailboxable
  attr_reader :email
  
  def initialize(email=Griddler::Email.new)
    @email = email
  end
  
  def save
    return unless valid?
    message = request.messages.create! \
      content:email,
      mailbox:mailbox,
      customer:customer,
      agent:agent
    
    Activity.new(request:request, owner:agent).reply message
  end
  
  def valid?
    request.present?
  end
  
  def request
    @request ||= Request.find_by_id(from_subject || from_recipients)
  end
  
  private
  
  def from_subject
    subject_request = /request#(\d+)/.match(email.subject)
    subject_request && subject_request[1]
  end
  
  def from_recipients
    recipient_regex = /request\.(\d+)@getsupportflow/
    recipient_request = recipients.find {|_| recipient_regex.match _ }
    recipient_request && recipient_regex.match(recipient_request)[1]
  end
  
  def customer
    return if agent.present?
    existing_customer || new_customer
  end
  
  def existing_customer
    request.team.customers.where(email_address:from).first
  end
  
  def new_customer
    Customer.create email_address:from, team:request.team
  end
  
  def agent
    request.team.agents.where(email_address:from).first
  end
end