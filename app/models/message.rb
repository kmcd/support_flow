class Message < ActiveRecord::Base
  belongs_to :mailbox
  belongs_to :request, counter_cache:true
  belongs_to :agent # TODO: change to belongs_to :owner, polymorphic:true
  belongs_to :customer
  serialize :content # TODO: serialize as (searchable) JSON
  before_create :set_subject_body
  
  def sender
    agent.present? ? agent : customer
  end
  
  def set_subject_body
    return unless content.present?
    self.subject = content.subject
    self.text_body = content.raw_text
  end
end
