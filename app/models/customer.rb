class Customer < ActiveRecord::Base
  has_many :requests
end
