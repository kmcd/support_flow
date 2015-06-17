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
  
  def timeline
    @timeline ||= Activity.
      where(
        "team_id = ? AND (
          ( owner_type = 'Agent' AND owner_id = ? ) OR
          ( recipient_type = 'Agent' AND recipient_id = ? ))", 
        team, id, id).
      group_by {|_| _.created_at.to_date }.
      sort_by &:first
  end
  
  def team_members
    team.agents.where.not(id:id).sort_by &:name
  end
end
