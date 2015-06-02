class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :customer_requests, :current_agent, :current_team
  # before_filter :require_login # TODO: integration test auth
  
  def customer_requests
    return [] if @request.blank?
    @request.customer.requests.where.not id:@request.id
  end
  
  def current_agent
    @current_agent ||= Agent.find_by_id session[:current_agent_id]
    Agent.first
  end
  
  def current_team
    current_agent.team
  end
  
  private
  
  def require_login
    return if current_agent.present?
    redirect_to '/login'
  end
end
