class InboundEmailJob < ActiveJob::Base
  attr_reader :payloads, :emails
  queue_as :default

  def perform(mandrill_payloads)
    initialise mandrill_payloads
    create_emails
    create_attachments
    process_arrivals
  end

  private

  def initialise(mandrill_payloads)
    @payloads = JSON.parse mandrill_payloads
    @emails = []
  end

  def create_emails
    payloads.each do |payload|
      next unless payload['event'] == 'inbound'
      
      # FIXME: set request, team from bcc request#id
      emails << Email.create!(payload:payload['msg'])
    end
  end

  def create_attachments
    payloads.each do |payload|
      next unless payload['event'] == 'inbound'
      next unless payload['msg'].has_key? 'attachments'

      payload['attachments'].each do |attachment|
        Email::Attachment.create \
          name:attachment['name'],
          type:attachment['type'],
          content:attachment['content'],
          base64:attachment['base64']
      end
    end
  end

  def process_arrivals
    emails.each do |_|
      EnquiryJob.perform_later _
      ReplyJob.perform_later _
      CommandJob.perform_later _
    end
  end
end
