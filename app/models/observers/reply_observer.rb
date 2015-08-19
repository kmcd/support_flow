class ReplyObserver < ActiveRecord::Observer
  observe Email::Inbound

  def after_create(email)
    email.process_reply
  end
end

Email::Inbound.class_eval do
  def process_reply
    return unless message.request_reply?
    return if only_commands_present?

    Activity.create \
      key:'request.reply',
      team:team,
      trackable:request,
      owner:sender,
      recipient:request.customer,
      parameters:{ 'email_id' => id }
      # TODO: add reply time:
  end

  private

  def only_commands_present?
    return unless message.command_arguments.present?
    [ message.text,  message.command_arguments ].uniq.one?
  end
end
