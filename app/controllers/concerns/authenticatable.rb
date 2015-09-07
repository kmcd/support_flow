module Authenticatable
  ADMINS = %w[ keith@dancingtext.com ]
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

    render_404
  end

  def authenticate_agent
    return if current_agent.present?

    redirect_to new_team_login_path(team_name)
  end

  def authorise_agent
    return if admin?
    return if current_agent.member?(current_team)

    render_404
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

  def render_404
    render file:"#{Rails.root}/public/404", layout:false, status: :not_found
  end
  
  def admin?
    ADMINS.include? current_agent.email_address
  end
end
