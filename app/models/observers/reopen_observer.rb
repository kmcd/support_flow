class ReopenObserver < ActiveRecord::Observer
  observe :request

  def after_update(request)
    return unless request.reopened?

    request.reopen_activity
    request.update_customer_index
  end
end

Request.class_eval do
  def reopen_activity
    create_activity :reopen
  end

  def reopened?
    return unless open_changed?
    return unless open?
  end
end
