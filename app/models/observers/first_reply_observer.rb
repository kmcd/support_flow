class FirstReplyObserver < ActiveRecord::Observer
  observe Email::Inbound

  def after_create(email)
    email.create_first_reply_activity
  end
end

Email::Inbound.class_eval do
  def create_first_reply_activity
    return unless first_reply?

    Activity.create \
      key:'request.reply_time',
      team:team,
      trackable:request,
      owner:sender,
      recipient:request.customer,
      parameters:{ 'seconds' => time_to_reply }
  end

  private

  def first_reply?
    return unless from_agent?
    return unless to_customer?
    return if Activity.exists?(trackable:request, key:'request.reply_time')
  end

  def to_customer?
    return unless request.present?
    return unless request.customer.present?

    message.recipient_addresses.include? request.customer.email_address
  end

  def time_to_reply
    (0.seconds.ago - request.created_at).to_i
  end
end
