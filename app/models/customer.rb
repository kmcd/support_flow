class Customer < ActiveRecord::Base
  include Profileable
  has_many :requests
  has_many :messages
  belongs_to :team
end
