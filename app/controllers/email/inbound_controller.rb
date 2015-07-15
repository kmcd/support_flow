class Email::InboundController < ApplicationController
  skip_before_filter :require_login
  skip_before_action :verify_authenticity_token
  before_filter :authenticate_webhook
  
  def index
    head :ok # Required by Mandrill
  end
  
  def create
    Email::Inbound.create_from mandrill_payload
    head :ok
  end
  
  private
  
  def authenticate_webhook # TODO: add Mandrill api/webhook auth keys
  end
  
  def mandrill_payload
    params['mandrill_events']
  end
end
