class EmailProcessorJob < ActiveJob::Base
  queue_as :default
  
  def perform(email_json)
    email = Griddler::Email.new JSON.parse(email_json["params"])
    
    # Enquiry.new(email).save
    # Reply.new(email).save
    # Command.new(email).execute
  end
end
