class Agent < ActiveRecord::Base
  include Profileable
  include Statistics
  belongs_to :team
  has_many :emails
  has_many :requests
  
  profile_entry %i[ name phone notes avatar ]
  
  def name
    profile['name'] || email_address
  end
  
  # FIXME: change to has_many polymorphic
  def activities
    Activity.where owner_id:id, owner_type:Agent
  end
end
