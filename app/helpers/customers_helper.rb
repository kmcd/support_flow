module CustomersHelper
  def request_open(activity)
    description = activity.trackable.name || "##{activity.trackable.id}"
    link_to(description, activity.trackable)
  end
  
  def open_requests_facet
    append_facet 'sort:open'
  end
  
  def closed_requests_facet
    append_facet 'sort:closed'
  end
end
