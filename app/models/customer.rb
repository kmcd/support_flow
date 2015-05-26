class Customer < ActiveRecord::Base
  include Profileable
  include Statistics
  has_many :requests
  has_many :emails
  belongs_to :team
  
  profile_entry %i[ name company phone notes avatar ]
  
  def name
    return profile['name'] unless profile['name'].blank?
    email_address
  end
  
  def activities
    PublicActivity::Activity.where owner_id:id, owner_type:Customer
  end
end
