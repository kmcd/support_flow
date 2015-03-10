class Request < ActiveRecord::Base
  belongs_to :agent
  belongs_to :customer
  has_many :messages
  before_save :ensure_unique_tags
  
  private
  
  def ensure_unique_tags
    return unless tags_changed?
    self.tags = tags.flatten.map(&:downcase).uniq
  end
end
