module ApplicationHelper
  def active_page(path)
    { :class => "#{'active' if current_page?(path)}" }
  end
end
