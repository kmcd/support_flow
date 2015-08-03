class Agent < ActiveRecord::Base
  include Statistics
  include Timelineable
  belongs_to :team
  has_many :emails
  has_many :requests
  validates :name, presence:true
  validates :email_address, presence:true
  after_create :set_notification_policy
  
  # FIXME: change to has_many polymorphic
  def activities
    Activity.where owner_id:id, owner_type:Agent
  end

  def team_members
    team.agents.where.not(id:id).sort_by &:name
  end
  
  private
  
  def set_notification_policy
    update notification_policy:{ open:true, close:true, assign:true }
  end
end
