class SignupsController < ApplicationController
  skip_before_action :authenticate_agent
  skip_before_action :authorise_agent

  def new
    @login = Login.new

    # TODO: create friendly signup copy
    render 'logins/new', layout:'logins'
  end

  def create
    @login = Login.new email:login_params[:email], signup:true

    if @login.save
      DemoJob.perform_later @login
    else
      render 'logins/new', layout:'logins'
    end
  end

  private

  def login_params
    params.require(:login).permit %i[ email ]
  end
end
