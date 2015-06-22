class Customer < ActiveRecord::Base
  include Indexable
  include Statistics
  has_many :requests
  has_many :emails
  belongs_to :team
  validates :email_address, presence:true, uniqueness:true
  # TODO: validate email_address format
  
  # TODO: move to RequestCount.new(customer).open
  def open_count
    Request.open_count self
  end
  
  def close_count
    Request.open_count self, false
  end
end
