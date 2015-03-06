class EmailProcessorJob < ActiveJob::Base
  queue_as :default
  
  def perform(email)
    Message.create_from email
  end
end
