class EnquiryObserver < ActiveRecord::Observer
  observe :message
  
  def after_create(message)
    # Enquiry.new(message).save
  end
end
