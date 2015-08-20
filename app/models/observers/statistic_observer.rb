class StatisticObserver < ActiveRecord::Observer
  observe Activity

  def after_save(activity)
    AgregateStatsJob.perform_later activity
  end
end

class AgregateStatsJob < ActiveJob::Base
  queue_as :default

  def perform(activity)
    activity.update_team_reply
    activity.update_team_close
    activity.update_agent_reply
    activity.update_agent_close
    activity.update_customer_reply
    activity.update_customer_close
  end
end

Activity.class_eval do
  delegate :team, to: :trackable

  def update_team_reply
    return unless team? && reply?

    Statistic::Reply.where(owner:team).first_or_initialize.
      update value:team_average
  end

  def update_team_close
    return unless team? && close?

    Statistic::Close.where(owner:team).order('id DESC').first_or_initialize.
      update value:team_average
  end

  def update_agent_reply
    return unless agent? && reply?

    Statistic::Reply.where(owner:owner).first_or_initialize.
      update value:agent_average
  end

  def update_agent_close
    return unless agent? && close?

    Statistic::Close.where(owner:owner).order('id DESC').first_or_initialize.
      update value:agent_average
  end

  def update_customer_reply
    return unless customer? && reply?

    Statistic::Reply.where(owner:recipient).first_or_initialize.
      update value:customer_average
  end

  def update_customer_close
    return unless customer? && close?

    Statistic::Close.where(owner:recipient).order('id DESC').
      first_or_initialize.update value:customer_average
  end

  def team?
    trackable.is_a? Request
  end

  def agent?
    owner.is_a? Agent
  end

  def customer?
    recipient.is_a? Customer
  end

  def reply?
    key =~ /request.reply_time/
  end

  def close?
    key =~ /request.close/
  end

  def team_average
    self.class.where( \
      key:key,
      trackable_id:trackable.team.requests.map(&:id),
      trackable_type:'Request').
        average_seconds
  end

  def agent_average
    self.class.where( \
      key:key,
      owner_id:owner.id,
      owner_type:'Agent').
        average_seconds
  end

  def customer_average
    self.class.where( \
      key:key,
      recipient_id:recipient.id,
      recipient_type:'Customer').
        average_seconds
  end
end

Enumerable.class_eval do
  def average_seconds
    map {|_| _.parameters['seconds'].to_i }.compact.sum / size
  end
end
