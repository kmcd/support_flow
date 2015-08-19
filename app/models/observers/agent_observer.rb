class AgentObserver < ActiveRecord::Observer
  def after_create(agent)
    agent.set_notification_policy
  end
end

Agent.class_eval do
  def set_notification_policy
    return if notification_policy.present?
    update notification_policy:{ open:true, close:true, assign:true }
  end
end
