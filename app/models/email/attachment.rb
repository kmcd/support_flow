class Email::Attachment < ActiveRecord::Base
  self.table_name = 'attachments'
  belongs_to :team
  belongs_to :email

  def self.create_from(params)
    params[:attachments].map do |attachment|
      create \
        team:params[:team],
        name:attachment.original_filename,
        content_type:attachment.content_type,
        content:Base64.encode64(attachment.read),
        base64:true,
        size:attachment.size
    end
  end
end
