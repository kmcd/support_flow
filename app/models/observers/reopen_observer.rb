class ReopenObserver < ActiveRecord::Observer
  observe :request

  def after_update(request)
    request.reopen_activity
  end
end

Request.class_eval do
  def reopen_activity
    return unless open_changed?
    return unless open?

    create_activity :reopen
  end
end
