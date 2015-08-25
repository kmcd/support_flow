class RenameObserver < ActiveRecord::Observer
  observe :request
  
  def after_update(request)
    request.rename_activity
  end
end

Request.class_eval do
  def rename_activity
    return unless name_changed?
    return unless name_was.present?

    Activity.create \
      key:'request.rename',
      team_id:team_id,
      trackable:self,
      owner:current_agent,
      parameters:{from:name_was, to:name}
  end
end
