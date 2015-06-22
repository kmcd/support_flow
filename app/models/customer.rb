class Customer < ActiveRecord::Base
  include Indexable
  include Profileable
  include Statistics
  has_many :requests
  has_many :emails
  belongs_to :team
  validates :email_address, presence:true, uniqueness:true
  # TODO: validate email_address format
  
  profile_entry %i[ name company phone notes avatar ]
  
  def name
    return profile['name'] unless profile['name'].blank?
    email_address
  end
  
  # TODO: move to acts_as_taggable ...
  def labels
    []
  end
  
  def open_count
    Request.open_count self
  end
  
  def close_count
    Request.open_count self, false
  end
end
