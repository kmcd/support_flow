class Agent < ActiveRecord::Base
  include Profileable
  belongs_to :team
  has_many :messages
end
