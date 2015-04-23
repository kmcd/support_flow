class Reply
  include Mailboxable
  attr_reader :email, :message
  
  def initialize(email=Griddler::Email.new)
    @email = email
  end
  
  def save
    return unless valid?
    @message = request.messages.create! \
      content:email,
      mailbox:mailbox,
      customer:customer,
      agent:agent
    activity = Activity.new request:request, owner:agent,
      recipient:request.customer
    activity.reply message
    activity.first_reply_time if first?
    self
  end
  
  def valid?
    return unless request.present?
    content_present?
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
    # FIXME: request replied to from mailbox email_address
    Customer.create email_address:from, team:request.team
  end
  
  def agent
    request.team.agents.where(email_address:from).first
  end
  
  def content_present?
    email.body.gsub(/\A\s*--\w+.*\Z/m, '').present?
  end
  
  def first?
    return unless agent.present?
    return unless recipients.include?(message.request.customer.email_address)
    
    PublicActivity::Activity.where(trackable:message,
      key:'request.first_reply').empty?
  end
end