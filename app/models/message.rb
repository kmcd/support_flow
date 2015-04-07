class Message < ActiveRecord::Base
  belongs_to :mailbox
  belongs_to :request, counter_cache:true
  belongs_to :agent
  belongs_to :customer
  serialize :content
  
  def sender
    agent.present? ? agent : customer
  end
end
