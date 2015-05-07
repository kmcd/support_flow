class EmailProcessor
  attr_reader :email
  
  def initialize(email)
    @email = email
  end
  
  def process
    Enquiry.new(email).save
    Reply.new(email).save
    Command.new(email).execute
  end
end