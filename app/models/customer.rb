class Customer < ActiveRecord::Base
  include Indexable
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
    Activity.where owner_id:id, owner_type:Customer
  end
  
  def labels
    []
  end
  
  def timeline
    @timeline ||= Activity.
      where(
        "team_id = ? AND (
          ( owner_type = 'Customer' AND owner_id = ? ) OR
          ( trackable_type = 'Customer' AND trackable_id = ? ) OR
          ( recipient_type = 'Customer' AND recipient_id = ? ))", 
        team, id, id, id).
      group_by {|_| _.created_at.to_date }.
      sort_by &:first
  end
end
