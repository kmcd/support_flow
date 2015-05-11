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
    authentication = Authentication.new params[:id]
    
    if authentication.valid?
      @current_agent = authentication.agent
      redirect_to requests_path
    else
      # FIXME: error messages
      redirect_to new_sessions_path
    end
  end
  
  def session_params
    params.require(:session).permit %i[ email ]
  end
end
