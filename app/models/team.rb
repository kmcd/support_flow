class Team < ActiveRecord::Base
  has_many :agents
  has_many :customers
  has_many :guides
  has_many :mailboxes
  has_many :messages, through: :mailboxes
end
