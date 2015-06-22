class Request < ActiveRecord::Base
  include Indexable
  include Labelable
  belongs_to :agent
  belongs_to :customer
  belongs_to :team
  has_many :emails
  has_many :activities, -> { where trackable_type:name  },
    foreign_key:'trackable_id'
  after_create :set_number
  after_commit :save_close_time, if: :closing?

  # TODO: move to RequestCount.new(agent).open
  scope :open_count, ->(filter, open=true) {
    options = { open:open }
    options.merge!({ team:filter })     if filter.is_a?(Team)
    options.merge!({ agent:filter })    if filter.is_a?(Agent)
    options.merge!({ customer:filter }) if filter.is_a?(Customer)
    where( options ).count
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

  def assigned?
    agent_id.present?
  end
  
  def first_reply
    Statistic::Reply.where(owner:self).first_or_initialize.value.to_i / 60
  end
  
  private

  # TODO: move to RequestCloseJob
  def save_close_time
    return unless now_closing?

    activities.create key: :close_time,
      owner:agent,
      recipient:customer,
      parameters:{seconds:(Time.now - created_at.to_time).to_i}
  end

  def set_number
    update number:Request.count
  end

  def closing?
    previous_changes[:open].present? && \
      previous_changes[:open] == [true, false]
  end
end
