class Team < ActiveRecord::Base
  include Statistics
  has_many :requests
  has_many :guides
  has_many :assets
  has_many :agents
  has_many :customers
  has_many :emails
  validates :name, presence:true, uniqueness:true
  
  # TODO: replace with acts_as_taggable
  def labels
    ActiveRecord::Base.connection.exec_query( \
      %Q{
        SELECT tag
        FROM
          (SELECT DISTINCT unnest(requests.labels) as tag
          FROM "requests"
          WHERE requests.team_id = #{self.id}) subquery
      }).
      rows.flatten.sort
  end
  
  def to_param
    name
  end
end
