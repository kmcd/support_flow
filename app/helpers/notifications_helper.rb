module NotificationsHelper
  def notification_check_box(policy)
    check_box_tag \
      "notification_policy[#{policy.to_s}]", 
      true,
      current_agent.notification_policy[policy.to_s] == 'true'
  end
end