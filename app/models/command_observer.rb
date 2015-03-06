class CommandObserver < ActiveRecord::Observer
  observe :message
  
  def after_create(message)
    return unless command? message
    # find or create customer record
    # find team mail box
    # create customer request
  end
end
