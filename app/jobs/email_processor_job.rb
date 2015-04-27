class EmailProcessorJob < ActiveJob::Base
  queue_as :default
  
  def perform(email_json)
    email = JSON.parse email_json
    Enquiry.new(email).save
    Reply.new(email).save
    Command.new(email).execute
  end
end
