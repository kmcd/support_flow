class Email::InboundController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_agent
  skip_before_action :authorise_agent
  skip_before_action :authenticate_team

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
    return [] unless params['mandrill_events']

    JSON.parse params['mandrill_events']
  end
end
