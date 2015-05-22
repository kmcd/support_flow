class ReplyJob < ActiveJob::Base
  attr_reader :email, :request
  queue_as :default

  def perform(email)
    initialise email
    return unless valid?
    add_email_to_request
    update_activity_stream
  end

  private

  def initialise(email)
    @email = email
    @request = Request.find_by_id(subject || recipients)
  end

  def valid?
    email.present? && request.present?
  end

  def add_email_to_request
    email.update request:request
  end

  def update_activity_stream
    activity.first_reply_time if first_reply?
    activity.reply email
  end

  def subject
    subject_request = /request.(\d+)/.match(email.subject)
    subject_request && subject_request[1]
  end

  def recipients
    recipient_regex = /request\.(\d+)@getsupportflow/
    recipient_request = email.message.recipient_addresses.
      find {|_| recipient_regex.match _ }
    recipient_request && recipient_regex.match(recipient_request)[1]
  end

  def activity
    Activity.new request:request, owner:agent, recipient:request.customer
  end

  def first_reply?
    return unless from_agent? && to_customer?
    PublicActivity::Activity.where(trackable:email,
      key:'request.first_reply').empty?
  end

  def from_agent?
    agent.present?
  end

  def to_customer?
    email.message.recipient_addresses.
      include?(request.customer.email_address)
  end
  
  def agent
    return unless request && request.team
    @agent = request.team.agents.where(email_address:email.from).first
  end
end
