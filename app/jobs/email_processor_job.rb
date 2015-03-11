class EmailProcessorJob < ActiveJob::Base
  queue_as :default
  
  def perform(email)
    Enquiry.new(email).save
    Reply.new(email).save
    Command.new(email).execute
  end
end
