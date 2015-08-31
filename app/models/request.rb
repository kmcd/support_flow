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
    Activity.
      where(key:'request.reply_time', trackable:self).
      first.
      try {|_| _.parameters['seconds'] }
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
  
  def update_customer_index
    return unless customer.present?

    IndexJob.perform_later customer, 'update'
  end
end
