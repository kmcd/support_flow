class Message < ActiveRecord::Base
  belongs_to :mailbox
  belongs_to :request
  belongs_to :agent
  belongs_to :customer
  
  def self.create_from(email)
    # Find Mailbox if possible
    # Create message
  end
end
