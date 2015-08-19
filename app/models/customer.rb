class Customer < ActiveRecord::Base
  include Labelable
  include Statistics
  include Timeline
  include RequestCount
  has_many :requests
  has_many :emails
  belongs_to :team
end
