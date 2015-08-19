class CloseObserver < ActiveRecord::Observer
  observe :request

  def after_update(request)
    request.close_activity
  end
end

Request.class_eval do
  def close_activity
    return unless closing?

    create_activity :close,
      recipient:customer,
      parameters:{ 'seconds' => close_time_in_seconds }
  end

  def close_time_in_seconds
    (0.minutes.ago - created_at).to_i
  end
end
