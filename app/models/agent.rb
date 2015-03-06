class Agent < ActiveRecord::Base
  belongs_to :team
  has_many :messages
end
