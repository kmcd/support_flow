class RequestObserver < ActiveRecord::Observer
  def after_create(request)
    request.set_number
  end
end

Request.class_eval do
  def set_number
    update number:Request.count
  end
end
