module ApplicationHelper
  def active_page(controller_name)
    return {} unless controller.controller_name == controller_name.to_s
    { :class => 'active' }
  end
  
  def duration(seconds)
    seconds = seconds.to_i + rand(60*rand(5))
    _, sec = seconds.divmod 60
    _, mins = _.divmod 60
    days, hours = _.divmod 60
    [ hours, mins ]
  end
end
