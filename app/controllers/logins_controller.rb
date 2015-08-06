class LoginsController < ApplicationController
  skip_before_action :authenticate_agent
  skip_before_action :authorise_agent

  def new
    @login = Login.new
  end

  def create
    @login = Login.where(email:login_params[:email]).first_or_initialize

    if @login.save
      LoginMailer.login_email(@login).deliver_later
    else
      flash[:notice] = :login_error
      redirect_to new_login_path
    end
  end

  def show
    authentication = Authentication.new params[:token]

    if authentication.valid?
      agent = authentication.agent
      session[:current_agent_id] = agent.id
      session[:current_team_id] = agent.team.id
      redirect_to team_path(agent.team.name)
    else
      flash[:notice] = :login_error
      redirect_to new_login_path
    end
  end

  def destroy
    session[:current_agent_id] = nil
  end

  def login_params
    params.require(:login).permit %i[ email ]
  end
end
