class Request < ActiveRecord::Base
  belongs_to :mailbox
  belongs_to :agent
  belongs_to :customer
  has_many :messages
  
  # TODO: before save downcase & reject duplicate tags
end
