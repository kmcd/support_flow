class PublicGuide
  attr_reader :team, :guide
  
  def initialize(team_name, guide_name)
    @team = Team.where(name:team_name).first
    @guide = team.guides.where(name:guide_name.titleize).first if team
  end
  
  def present?
    team && guide
  end
  
  def html
    return unless guide.present?
    template = Guide.template team
    template.content.gsub! /(<!-- content -->)/, "\\1 \n#{guide.content}"
    template.content.html_safe
  end
  
  def increment_view_count(current_agent=nil)
    return unless guide.present?
    return if team.agents.include?(current_agent)
    guide.increment! :view_count
  end
end