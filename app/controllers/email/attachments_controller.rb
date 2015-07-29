class Email::AttachmentsController < ApplicationController
  layout false
  include Attachable

  def show
    @attachment = current_team.attachments.find params[:id]
    
    send_data \
      @attachment.content,
      filename:@attachment.name,
      type:@attachment.content_type
  end
  
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
