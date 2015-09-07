class AgentObserver < ActiveRecord::Observer
  def before_create(agent)
    agent.set_notification_policy
  end

  def after_create(agent)
    agent.dispatch_invitation
  end
end

Agent.class_eval do
  def set_notification_policy
    return if notification_policy.present?

    self.notification_policy = { open:true, close:true, assign:true }
  end

  def dispatch_invitation
    return if lead_agent?

    AgentMailer.invitation(self).deliver_later
  end
  
  private
  
  def lead_agent?
    team.agents.first.eql? self
  end
end

class SalesObserver
  # after signup ...
  # after trial ...
  # after payment ...
end
