class AssignmentObserver < ActiveRecord::Observer
  observe :request
  
  def after_update(request)
    request.assignment_activity
  end
end

Request.class_eval do
  def assignment_activity
    return unless agent_id_changed?
  
    Activity.create \
      key:'request.assign',
      trackable:self,
      owner:current_agent,
      recipient:agent
  end
end
