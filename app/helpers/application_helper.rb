module ApplicationHelper
  def active_page(controller_name)
    return {} unless controller.controller_name == controller_name.to_s
    { :class => 'active' }
  end
end
