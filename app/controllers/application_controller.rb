class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :current_agent, :current_team
  before_filter :authenticate_agent
  before_filter :authorise_agent

  def current_agent
    @current_agent ||= Agent.find_by_id session[:current_agent_id]
  end

  def current_team
    current_agent.team
  end

  private

  def authenticate_agent
    return if current_agent.present?
    redirect_to new_login_path
  end

  def authorise_agent
    return if current_agent.team == current_team
    render file:"#{Rails.root}/public/404", status: :not_found
  end

  def search_query
    # TODO: move default 'sort:new' to lib/searchable.rb
    params[:q].present? ? params[:q] : 'sort:new'
  end
end
