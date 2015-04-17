module CustomersHelper
  def request_open(activity)
    description = activity.trackable.name || "##{activity.trackable.id}"
    link_to(description, activity.trackable)
  end
end
