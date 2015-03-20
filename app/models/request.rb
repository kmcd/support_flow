class Request < ActiveRecord::Base
  include PublicActivity::Common
  belongs_to :agent
  belongs_to :customer
  has_many :messages, dependent: :destroy
  belongs_to :team
  
  def assign_from(name_or_email)
    return unless assignee = team.agents.
      where("email_address SIMILAR TO ? OR email_address = ?",
      "%#{name_or_email}%@%", name_or_email ).
      first
    update_attributes agent:assignee
  end
  
  # TODO: replace with https://github.com/tmiyamon/acts-as-taggable-array-on
    before_save :ensure_unique_tags
    
    def tag_with(tag_list)
      seperator = /(\s|,)/
      tags << tag_list.
        split(seperator).
        reject {|_| _[seperator] || _.blank? }
      save!
    end
    
    def ensure_unique_tags
      return unless tags_changed?
      self.tags = tags.flatten.map(&:downcase).uniq
    end
  
  def name
    messages.first.content.subject # FIXME: extract name from subject
  end
end
