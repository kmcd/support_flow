class Agent < ActiveRecord::Base
  include Profileable
  belongs_to :team
  has_many :messages
  has_many :requests
  
  profile_entry %i[ name phone notes avatar ]
  
  def name
    profile['name'] || email_address
  end
  
  def activities
    PublicActivity::Activity.where owner_id:id, owner_type:Agent
  end
end
