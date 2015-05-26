class ReplyJob < ActiveJob::Base
  attr_reader :email
  delegate :request, :agent, to: :email
  queue_as :default

  def perform(email)
    initialise email
    return unless valid?
    update_activity_stream
  end

  private

  def initialise(email)
    @email = email
    email.associate_request
  end

  def valid?
    email.present? && request.present?
  end

  def update_activity_stream
    activity.first_reply_time if first_reply?
    activity.reply email
  end

  def activity
    @activity ||= Activity.new request:request, owner:agent,
      recipient:request.customer
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
end
