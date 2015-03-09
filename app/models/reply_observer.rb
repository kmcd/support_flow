class ReplyObserver < ActiveRecord::Observer
  observe :message
  
  def after_create(message)
    # return unless reply? message
    # find or create customer record
    # find team mail box
    # create customer request
  end
end
