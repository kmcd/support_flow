class LoginsController < ApplicationController
  skip_before_action :authenticate_agent
  skip_before_action :authorise_agent

  def new
    @login = Login.new
  end

  def create
    @login = Login.new login_params

    unless @login.save
      flash[:notice] = :login_error
      redirect_to new_team_login_path(current_team)
    end
  end

  def show
    authentication = Authentication.new params[:token]

    if authentication.valid?
      agent = authentication.agent
      session[:current_agent_id] = agent.id
      session[:current_team_id] = current_team
      redirect_to team_path(current_team)
    else
      flash[:notice] = :login_error
      redirect_to new_team_login_path
    end
  end

  def destroy
    session[:current_agent_id] = nil
  end

  def login_params
    params.
      require(:login).
      permit(%i[ email_address ]).
      merge!( team:current_team )
  end
end
