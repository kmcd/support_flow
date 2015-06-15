class LoginsController < ApplicationController
  skip_before_action :require_login
 
  def new
    @login = Login.new
  end
  
  def create
    @login = Login.where(email:login_params[:email]).first_or_initialize
    
    if @login.save
      LoginMailer.login_email(@login).deliver_now # FIXME: enqueue
    else
      render :new
    end
  end
  
  # TODO: should ~really~ be a singular resource token param in GET request
  def show
    authentication = Authentication.new params[:id]
    
    if authentication.valid?
      agent = authentication.agend
      session[:current_agent_id] = agent.id
      session[:current_team_id] = agent.team.id
      redirect_to team_path(agent.team.name)
    else
      redirect_to new_login_path # FIXME: error message
    end
  end
  
  def destroy
    session[:current_agent_id] = nil
  end
  
  def login_params
    params.require(:login).permit %i[ email ]
  end
end
