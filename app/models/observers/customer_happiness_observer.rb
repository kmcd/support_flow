class CustomerHappinessObserver < ActiveRecord::Observer
  observe :request
  
  def after_update(request)
    request.customer_happiness_activity
  end
end

Request.class_eval do
  def customer_happiness_activity
    return unless happiness_changed?

    create_activity :happiness,
      recipient:customer,
      parameters:{ was:happiness_was, now:happiness }
  end
end
