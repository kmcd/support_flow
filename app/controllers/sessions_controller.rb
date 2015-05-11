# TODO: rename resource to Login
class SessionsController < ApplicationController
  def new
    @session = Session.new
  end
  
  def create
    @session = Session.where(email:session_params[:email]).first_or_initialize
    
    if @session.save
      # TODO: should this be enqueued?
      LoginMailer.login_email(@session).deliver_now
    else
      render :new
    end
  end
  
  def show
    authentication = Authentication.new params[:token]
    
    if authentication.valid?
      agent = Agent.where email_address:authentication.session.email
      redirect_to team_path(agent.team)
    else
      # errors
    end
  end
  
  def session_params
    params.require(:session).permit %i[ email ]
  end
end
