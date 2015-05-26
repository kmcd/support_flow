class Request < ActiveRecord::Base
  include PublicActivity::Common
  belongs_to :agent
  belongs_to :customer
  belongs_to :team
  has_many :emails
  acts_as_taggable_array_on :labels
  after_commit :save_close_time
  
  scope :open, -> { where open:true }
  scope :closed, -> { where open:false }
  
  scope :open_count, ->(filter, open=true) {
    options = { open:open }
    options.merge!({ team:filter })     if filter.is_a?(Team)
    options.merge!({ agent:filter })    if filter.is_a?(Agent)
    options.merge!({ customer:filter }) if filter.is_a?(Customer)
    where( options ).count
  }
  
  scope :unanswered, -> {
    joins(:activities).
      where("activities.trackable_type = 'Request'").
      where.not("activities.key = 'request.first_reply'")
  }
  
  # TODO: move to RequestAssignmentJob ->
  # validate, carry out assignment, update activity stream ...
  def assign_from(name_or_email)
    return unless assignee = team.agents.
      where("email_address SIMILAR TO ? OR email_address = ?",
      "%#{name_or_email}%@%", name_or_email ).
      first
    update_attributes agent:assignee
  end
  
  # TODO: use taggable gem
  # TODO: move to RequestLabelJob -> update labels & activity stream
  def label=(label)
    return if label.gsub(/\W/,'').blank?
    
    self.labels = if label[/\A\-/]
      self.labels - [ label.gsub(/\A\-/,'') ]
    else
      self.labels | [label]
    end
  end
  
  private
  
  # TODO: move to RequestCloseJob ->
  # validate, close request, update activity stream
  def save_close_time
    return unless previous_changes[:open].present?
    return unless previous_changes[:open] == [true, false]
    
    create_activity :close_time, owner:agent, recipient:customer,
      params:{seconds:(Time.now - created_at.to_time).to_i}
  end
end
