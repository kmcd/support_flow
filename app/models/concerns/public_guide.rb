class PublicGuide
  attr_reader :team, :guide

  def initialize(team_name, slug)
    @team = Team.where(name:team_name).first
    @guide = team.guides.where(slug:slug.to_s).first
  end

  def html
    return unless guide.present?
    template = Guide.template team
    template.content.gsub! /(<!-- content -->)/, "\\1 \n#{guide.content}"
    template.content.html_safe
  end

  def increment_view_count(current_agent=false)
    return if current_agent
    return unless guide.present?

    guide.increment! :view_count
  end
end