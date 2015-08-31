class SignupsController < ApplicationController
  skip_before_action :authenticate_team
  skip_before_action :authenticate_agent
  skip_before_action :authorise_agent
  layout 'logins'

  def new
    @login = Login.new
  end

  def create
    @login = Login.new \
      email_address:login_params[:email_address],
      signup:true

    unless @login.save
      flash[:errors] = :signup
      render :new
    end
  end

  private

  def login_params
    params.
      require(:login).
      permit %i[ email_address ]
  end
end
