class Team < ActiveRecord::Base
  has_many :agents
  has_many :customers
  has_many :guides
  has_many :mailboxes
  has_many :messages, through: :mailboxes
  
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
end
