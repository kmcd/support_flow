class SignupsController < ApplicationController
  skip_before_action :require_login
  
  def new
    @login = Login.new
  end

  def create 
    @login = Login.where(email:login_params[:email]).first_or_initialize
    
    if @login.save
      create_team @login
      LoginMailer.signup_email(@login).deliver_now # FIXME: enqueue
    else
      render :new
    end
  end
  
  private
  
  def login_params
    params.require(:login).permit %i[ email ]
  end
  
  
  def create_team(login)
    # TODO: move to Signup service object & test
    team = Team.create
    team.agents.create email_address:login.email
    
    # FIXME: create more helpful default pages
    team.guides.create name:'index',
      content:'<h1>Welcome to Support Flow</h1>'
    team.guides.create name:'_template',
      content:"content: '<html><!-- content --></html>'"
      
    team.mailboxes.create email_address:"team.#{team.id}@getsupportflow.net"
  end
end
