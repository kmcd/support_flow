class Email::InboundController < ApplicationController
  skip_before_filter :require_login
  skip_before_action :verify_authenticity_token

  def index
    head :ok # Required by Mandrill
  end

  def create
    payloads.each do |payload|
      Email::Inbound.create payload:payload
    end

    head :ok
  end


  private

  def payloads
    JSON.parse params['mandrill_events']
  end
end
