class Customer < ActiveRecord::Base
  include Indexable
  include Labelable
  include Statistics
  has_many :requests
  has_many :emails
  belongs_to :team
  validates :name, presence:true, uniqueness:true
  
  # TODO: move to RequestCount.new(customer).open
  def open_count
    Request.open_count self
  end
  
  def close_count
    Request.open_count self, false
  end
end
