class Request < ActiveRecord::Base
  include PublicActivity::Common
  belongs_to :agent
  belongs_to :customer
  has_many :messages, dependent: :destroy
  belongs_to :team
  acts_as_taggable_array_on :labels
  
  def assign_from(name_or_email)
    return unless assignee = team.agents.
      where("email_address SIMILAR TO ? OR email_address = ?",
      "%#{name_or_email}%@%", name_or_email ).
      first
    update_attributes agent:assignee
  end
  
  def label_with(label_list, seperator=/(\s|,)/)
    self.labels += label_list.
      split(seperator).
      reject {|_| _[seperator] || _.blank? }
    save!
  end
    
  def name
    # FIXME: extract name from subject & set field
    messages.first.content.subject 
  end
end
