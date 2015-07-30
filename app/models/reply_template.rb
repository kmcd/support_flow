class ReplyTemplate < ActiveRecord::Base
  belongs_to :team
  validates :name, uniqueness:{ scope:'team_id' }
end
