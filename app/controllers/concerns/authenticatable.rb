module Authenticatable
  extend ActiveSupport::Concern
  
  included do
    before_filter :authenticate_team
    before_filter :authenticate_agent
    before_filter :authorise_agent
    helper_method :current_agent, :current_team
  end
  
  private

  def authenticate_team
    return if current_team.present?

    redirect_to '/404.html'
  end

  def authenticate_agent
    return if current_agent.present?

    redirect_to new_team_login_path(team_name)
  end

  def authorise_agent
    return if current_agent.member?(current_team)

    redirect_to '/404.html'
  end

  def team_name
    params[:team_name] || params[:name]
  end

  def current_team
    @current_team ||= if team_name.present?
      Team.where(name:team_name).first
    else
      Team.find_by_id session[:current_team_id]
    end
  end

  def current_agent
    @current_agent ||= Agent.find_by_id session[:current_agent_id]
  end
end
