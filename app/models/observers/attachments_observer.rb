class AttachmentsObserver < ActiveRecord::Observer
  observe Email::Inbound
  
  def after_create(email)
    email.extract_attachments
  end
end

Email::Inbound.class_eval do
  # FIXME: remove binary content from log files
  # FIXME: remove dulicated binary content from payload ?
  # TODO: remove attachments table & store binary attachments in json?
  # (i.e. make attachments consistent with inbound email messages)
  # e.g. replace table with conditional, select association
  # has_many :attachments, select: :payload ...
  # Or is this ~too~ clever ?
  def extract_attachments
    return unless payload['msg'].has_key? 'attachments'

    payload['msg']['attachments'].each do |name,file|
      team.attachments.create \
        email:self,
        name:file['name'],
        content_type:file['type'],
        content:file['content'],
        base64:file['base64']
    end
  end
end
