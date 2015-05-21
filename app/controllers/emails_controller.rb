class EmailsController < ApplicationController
  skip_before_filter :require_login
  before_filter :authenticate_webhook
  
  def index
    head :ok # Required by Mandrill
  end
  
  def create
    PayloadJob.perform_now params['mandrill_events']
    head :ok
  end
  
  private
  
  def authenticate_webhook
    # TODO: add Mandrill api/webhook auth keys
  end
end
