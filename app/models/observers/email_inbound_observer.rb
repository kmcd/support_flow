class EmailInboundObserver < ActiveRecord::Observer
  observe Email::Inbound

  def before_validation(email)
    email.set_team
    email.set_recipients
  end
end

Email::Inbound.class_eval do
  def set_team
    self.team = addressed_to_team || team_from_addressed_to_request
  end

  def set_recipients
    self.recipients = message.recipient_addresses.join ' '
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
