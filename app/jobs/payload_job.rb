class PayloadJob < ActiveJob::Base
  attr_reader :events, :emails
  queue_as :default

  def perform(mandrill_events)
    @events, @emails = JSON.parse(mandrill_events), []
    create_emails
    create_attachments
    create_enquiries
    update_replies
    execute_commands
  end
  
  private
  
  def create_emails
    email_payloads.each do |payload|
      emails << Email.create!(payload:payload)
    end
  end
  
  def create_attachments
    email_attachments.each do |attachment|
      # FIXME: set email_id!
      Attatchment.create \
        name:     attachment['name'],
        type:     attachment['type'],
        content:  attachment['content'],
        base64:   attachment['base64']
    end
  end
  
  def email_payloads
    events.find_all {|_| _['event'] == 'inbound' }
  end
  
  def email_attachments
    email_payloads.find_all {|_| _['attachments'].tap &:any? }
  end
  
  def create_enquiries
    emails.each {|email| EnquiryJob.perform_later email }
  end
  
  def update_replies
    emails.each {|email| ReplyJob.perform_later email }
  end
  
  def execute_commands
    emails.each {|email| CommandJob.perform_later email }
  end
end
