class ReplyObserver < ActiveRecord::Observer
  observe :message
  
  def after_create(message)
    Reply.new(message).save
  end
end
