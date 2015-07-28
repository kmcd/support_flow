module CustomersHelper
  def request_open(activity)
    description = activity.trackable.name || "##{activity.trackable.id}"
    link_to description, activity.trackable
  end
  
  def open_requests_facet
    append_facet 'sort:open'
  end
  
  def closed_requests_facet
    append_facet 'sort:closed'
  end
  
  def name_input_placeholder
    if @customer.errors[:name].present?
      @customer.errors[:name].join ','
    else
      "Customer name e.g. Billing enquiry"
    end
  end
end
