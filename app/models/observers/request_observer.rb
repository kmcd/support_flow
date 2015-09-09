class RequestObserver < ActiveRecord::Observer
  def after_create(request)
    request.set_number
    request.update_customer_index
  end

  def after_update(request)
    request.create_assignment_activity
  end
end

Request.class_eval do
  def set_number
    update number:team.requests.count
  end

  def create_assignment_activity
    return unless agent_id_changed?

    Activity.create \
      key:'request.assign',
      team:self.team,
      trackable:self,
      owner:current_agent,
      recipient:agent
  end
end
