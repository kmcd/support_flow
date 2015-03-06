class EmailProcessor
  attr_reader :email
  
  def initialize(email)
    @email = email
  end
  
  def process
    EmailProcessorJob.perform_later email
  end
end