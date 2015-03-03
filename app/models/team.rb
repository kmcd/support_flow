class Team < ActiveRecord::Base
  has_many :agents
  has_many :events
  has_many :guides
  has_many :mailboxes
  has_many :messages, through: :mailboxes
  has_many :search_documents
end
