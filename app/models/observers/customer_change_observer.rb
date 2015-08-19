class CustomerChangeObserver < ActiveRecord::Observer
  observe :request
  
  def after_update(request)
    request.change_customer_activity
  end
end

Request.class_eval do
  def change_customer_activity
    return unless customer_id_changed?
    return unless customer_id_was.present?

    create_activity :customer,
      recipient:customer,
      parameters:{ previous_customer_id:customer_id_was }
  end
end
