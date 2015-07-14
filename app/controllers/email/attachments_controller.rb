class Email::AttachmentsController < ApplicationController
  include Attachable

  def destroy
    @attachment = current_team.attachments.find params[:id]
    @attachment.delete
    session_attachment_ids.delete @attachment.id
  end

  private

  def attachment_params
    params.require(:attachment).permit [ :id ]
  end
end
