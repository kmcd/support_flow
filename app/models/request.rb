class Request < ActiveRecord::Base
  belongs_to :agent
  belongs_to :customer
  has_many :messages
  belongs_to :team
  
  before_save :ensure_unique_tags
  
  def assign_from(name_or_email)
    return unless assignee = team.agents.
      where("email_address SIMILAR TO ? OR email_address = ?",
      "%#{name_or_email}%@%", name_or_email ).
      first
    request.agent = assignee
    request.save!
  end
  
  def tag_with(tag_list)
    seperator = /(\s|,)/
    request.tags << tag_list
      .split(seperator).
      reject {|_| _[seperator] || _.blank? }
    request.save!
  end
  
  private
  
  def ensure_unique_tags
    return unless tags_changed?
    self.tags = tags.flatten.map(&:downcase).uniq
  end
end
