class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_agent, :current_team

  # TODO: integration test auth
  # before_filter :authenticate_agent
  # before_filter :authorise_agent

  def current_agent
    # @current_agent ||= Agent.find_by_id session[:current_agent_id]
    Agent.first
  end

  def current_team
    # current_agent.team
    Team.first
  end

  private

  def authenticate_agent
    return if current_agent.present?
    redirect_to '/login'
  end

  def authorise_agent
    return unless current_agent.team == current_team
  end

  # TODO: remove sort:new from default search box
  def search_query
    params[:q].present? ? params[:q] : 'sort:new'
  end
end
