class Email::OutboundController < ApplicationController
  before_action :set_outbound_email, only: %i[ update destroy ]

  def create
    @outbound_email = Email::Outbound.new outbound_email_params

    if @outbound_email.save
      # AgentMailer.reply(@outbound_email).deliver_later
    else
      render :error
    end
  end

  def update
    @outbound_email.update outbound_email_params
  end

  def destroy
    @outbound_email.destroy
  end

  private

  def outbound_email_params
    valid_attributes = [ :recipients, :message_content, attachments:[] ]
    ownership = { team:current_team, sender:current_agent }
    params.require(:email_outbound).
      permit(valid_attributes).
      merge!(ownership)
  end

  def set_outbound_email
    @outbound_email = current_team.emails.outbound.find params[:id]
  end
end
