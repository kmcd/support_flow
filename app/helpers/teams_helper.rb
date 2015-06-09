module TeamsHelper
  def pluralized(open_requests)
    request_text = "request"
    open_requests > 1 ? request_text.pluralize : request_text
  end
end
