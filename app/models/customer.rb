class Customer < ActiveRecord::Base
  has_many :requests
  has_many :messages
  belongs_to :team
end
