class EmailProcessor
  attr_reader :mandrill_payload
  
  def initialize(mandrill_payload)
    @mandrill_payload = mandrill_payload
  end
  
  def process
    # TODO: remove this class, config Griddler use job directly
    # EmailProcessorJob.perform_later email.to_json
    
    email = Griddler::Email.new mandrill_payload
    Enquiry.new(email).save
    Reply.new(email).save
    Command.new(email).execute
  end
end