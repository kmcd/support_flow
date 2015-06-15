class PublicGuide
  attr_reader :team, :guide
  
  def initialize(name, name)
    @team = Team.where(name:name).first
    @guide = name.present? ? team_guide(name) : home_page
  end
  
  def present?
    guide.present?
  end
  
  def html
    return unless guide.present?
    template = Guide.template team
    template.content.gsub! /(<!-- content -->)/, "\\1 \n#{guide.content}"
  end
  
  def increment_view_count(current_agent=nil)
    return unless guide.present?
    return if team.agents.include?(current_agent)
    guide.increment! :view_count
  end
  
  private
  
  def team_guide(name)
    team.guides.where(name:name).first
  end
  
  def home_page
    Guide.index team
  end
end