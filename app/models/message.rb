class Message < ActiveRecord::Base
  include Indexable
  belongs_to :mailbox
  belongs_to :request
  belongs_to :agent
  belongs_to :customer
  
  # TODO: serialize Griddler::Email as JSON
  # TODO: create email value object
  serialize :content
  
  def sender
    agent.present? ? agent : customer
  end
end
