class Agent < ActiveRecord::Base
  include Statistics
  include Timeline
  include RequestCount

  validates :name, presence:true
  validates :email_address,
    presence:true,
    uniqueness:{ scope: :team_id },
    format:{ with: /\A[^@]+@[^@]+\z/ }

  belongs_to :team
  has_many :emails
  has_many :requests
  has_many :activities, as: :owner
  belongs_to :invitor, class_name:'Agent'
  
  scope :last_5_mins, ->() {
    where created_at: 5.minutes.ago.at_beginning_of_minute..1.minute.ago.at_end_of_minute
  }

  scope :support_flow_customers, ->() {
    joins(:team).
    where.not( teams:{ name:'help' } ).
    where("email_address NOT SIMILAR TO '@example\.(com|net|org)' ")
  }

  def team_members
    team.agents.where.not(id:id).sort_by &:name
  end

  def member?(team)
    team.agents.include? self
  end
end
