class AgentObserver < ActiveRecord::Observer
  def before_create(agent)
    agent.set_notification_policy
  end
  
  def after_create(agent)
    AgentMailer.invitation(agent).deliver_later
  end
end

Agent.class_eval do
  def set_notification_policy
    return if notification_policy.present?

    self.notification_policy = { open:true, close:true, assign:true }
  end
end
