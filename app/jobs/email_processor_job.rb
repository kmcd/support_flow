class EmailProcessorJob < ActiveJob::Base
  queue_as :default
  
  def perform(email_json)
    throw JSON.parse(email_json)
    # email = Griddler::Email.new 
    
    # Enquiry.new(email).save
    # Reply.new(email).save
    # Command.new(email).execute
  end
end
