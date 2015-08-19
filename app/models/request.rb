class Request < ActiveRecord::Base
  include Labelable
  include Timeline # TODO: move to controller decorator
  belongs_to :agent
  belongs_to :customer
  belongs_to :team
  has_many :emails
  attr_accessor :current_agent

  def assigned?
    agent.present?
  end

  def first_reply
    Statistic::Reply.owned_by(self).time
  end

  # TODO: find a more elegant solution for open/closed flag
  # (or rename open to closed?)
  def closed
    !open
  end
  alias_method :closed?, :closed

  def closed=(status)
    open = !status
  end

  def closing?
    closed? && open_was
  end

  def create_activity(key, options={})
    Activity.create( \
      { key:"request.#{key.to_s}",
        team:team,
        trackable:self,
        owner:current_agent
      }.merge!(options) )
  end
end
