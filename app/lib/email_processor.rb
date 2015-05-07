class EmailProcessor
  attr_reader :email
  
  def initialize(email)
    @email = email
  end
  
  def process
    # TODO: remove this class, config Griddler use job directly
    # EmailProcessorJob.perform_later email.to_json
    
    email = Griddler::Email.new email["params"]
    Enquiry.new(email).save
    Reply.new(email).save
    Command.new(email).execute
  end
end