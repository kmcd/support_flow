module ApplicationHelper
  def active_page(controller_name)
    return {} unless controller.controller_name == controller_name.to_s
    { :class => 'active' }
  end
  
  def statistic(type, owner)
    stat = "Statistic::#{type.to_s.classify}".constantize.
      where(owner:owner).first
    stat && stat.value
  end
end
