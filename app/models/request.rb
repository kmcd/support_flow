class Request < ActiveRecord::Base
  include Indexable
  include Labelable
  include Timelineable
  belongs_to :agent
  belongs_to :customer
  belongs_to :team
  has_many :emails
  attr_accessor :current_agent

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
    agent.present?
  end

  def first_reply
    Statistic::Reply.where(owner:self).first_or_initialize.value.to_i / 60
  end

  # TODO: find a more elegant solution for open/closed flag
  # (or rename open to closed?)
  def closed
    !open
  end

  def closed=(status)
    open = !status
  end

  alias_method :closed?, :closed

  def timeline
    Timeline.new self
  end
end
