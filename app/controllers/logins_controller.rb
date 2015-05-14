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
  
  def show
    authentication = Authentication.new params[:id]
    
    if authentication.valid?
      session[:current_agent_id] = authentication.agent.id
      redirect_to requests_path
    else
      redirect_to new_login_path # FIXME: error message
    end
  end
  
  def login_params
    params.require(:login).permit %i[ email ]
  end
end
