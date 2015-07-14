class Email::OutboundController < ApplicationController
  include Attachable

  def create
    upload_attachments && return if remotipart_submitted?
    @outbound_email = Email::Outbound.new outbound_email_params

    if @outbound_email.save
      session_attachment_ids.clear
      AgentMailer.reply(@outbound_email).deliver_later unless Rails.env.development?
    else
      render :error
    end
  end

  private

  def outbound_email_params
    params.require(:email_outbound).
      permit( [ :recipients, :message_content, attachments:[] ]).
      merge!( { team:current_team, sender:current_agent } )
  end

  def upload_attachments
    if attachments_under_limit? && uploads_under_limit?
      attachments = Email::Attachment.
        create_from outbound_email_params
      session_attachment_ids << attachments.map(&:id)
      session_attachment_ids.flatten!
    end
    
    respond_to do |format|
      format.js do
        render :upload_attachments, layout:false
      end
    end
  end
end
