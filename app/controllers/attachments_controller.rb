class AttachmentsController < ApplicationController
  def create
    @attachment = Attachment.new
    # Save attachment list in session
    # FIXME: clean up orphan files
  end
  
  def attachment_params
    params.require(:attachments).permit [ files:[] ]
  end
end
