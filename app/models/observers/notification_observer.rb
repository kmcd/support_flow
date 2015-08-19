class NotificationObserver < ActiveRecord::Observer
  observe :request

  def after_create(request)
    request.open_notification
  end

  def after_update(request)
    request.assignment_notification
    request.close_notification
  end
end

Request.class_eval do
  def open_notification
    return unless new_record?

    agents_notified_on :open do |agent|
      AgentMailer.open(agent, self).deliver_later
    end
  end

  def assignment_notification
    return unless agent_id_changed?

    agents_notified_on :assign do |agent|
      AgentMailer.assign(agent, self).deliver_later
    end
  end

  def close_notification
    return unless closing?

    agents_notified_on :close do |agent|
      AgentMailer.close(agent, self).deliver_later
    end
  end

  private

  def agents_notified_on(policy)
    team.agents.each do |agent|
      next unless agent.notification_policy
      next unless agent.notification_policy[policy.to_s] == 'true'
      yield agent
    end
  end
end
