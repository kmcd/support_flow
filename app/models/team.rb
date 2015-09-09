class Team < ActiveRecord::Base
  include Statistics
  has_many :requests
  has_many :guides
  has_many :assets
  has_many :agents
  has_many :customers
  has_many :emails
  has_many :attachments, class_name:'Email::Attachment'
  has_many :activities
  has_many :logins
  has_many :reply_templates
  validates :name, presence:true, uniqueness:true
  enum subscription: %i[ demo trial monthly annual ]

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
