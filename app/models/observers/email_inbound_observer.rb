class EmailInboundObserver < ActiveRecord::Observer
  observe Email::Inbound

  def before_validation(email)
    email.set_team
    email.set_recipients
  end
  
  def after_create(email)
    email.process_commands
  end
end

Email::Inbound.class_eval do
  def set_team
    self.team = addressed_to_team || team_from_addressed_to_request
  end

  def set_recipients
    self.recipients = message.recipient_addresses.join ' '
  end
  
  def process_commands
    return unless from_agent?
    return unless message.command_arguments.present?

    Command.new(self).execute
  end

  private

  def addressed_to_team
    Team.find_by_id message.team_id
  end

  def team_from_addressed_to_request
    return unless addressed_to_request.present?
    addressed_to_request.team
  end
end
