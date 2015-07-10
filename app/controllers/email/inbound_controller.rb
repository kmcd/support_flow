class Email::InboundController < ApplicationController
  skip_before_filter :require_login
  before_filter :authenticate_webhook
  
  def index
    head :ok # Required by Mandrill
  end
  
  def create
    InboundEmail.create_from mandrill_payload
    head :ok
  end
  
  private
  
  def authenticate_webhook # TODO: add Mandrill api/webhook auth keys
  end
  
  def mandrill_payload
    params['mandrill_events']
  end
end
