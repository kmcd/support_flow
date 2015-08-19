class StatisticObserver < ActiveRecord::Observer
  observe Activity

  def after_save(activity)
    AgregateStatsJob.perform_later activity
  end
end

class AgregateStatsJob < ActiveJob::Base
  queue_as :default

  def perform(activity)
    activity.update_agregate_statistic
  end
end

Activity.class_eval do
  def update_agregate_statistic
    return unless statistic.present?

    owners.each do |_|
      statistic.
        where(owner:_).
        first_or_initialize.
        update value:activities(owner).average_seconds
    end
  end

  private

  def owners
    o = []
    o.push(trackable.team)  if trackable.is_a?(Request)
    o.push(owner)           if owner.is_a?(Agent)
    o.push(recipient)       if recipient.is_a?(Customer)
    o
  end

  def statistic
    case key.to_s
      when /request\.reply/ ; Statistic::Reply
      when /close/          ; Statistic::Close.order('id DESC')
    end
  end

  def activities(owner)
    return team_activities  if owner.is_a?(Request)
    return agent_activities if owner.is_a?(Agent)
    customer_activities     if owner.is_a?(Customer)
  end

  def team_activities
    request_ids = trackable.team.requests.map &:id

    Activity.where \
      key:key,
      trackable_id:request_ids,
      trackable_type:'Request'
  end

  def agent_activities
    Activity.where \
      key:key,
      owner_id:owner.id,
      owner_type:'Agent'
  end

  def customer_activities
    Activity.where \
      key:key,
      recipient_id:recipient.id,
      recipient_type:'Customer'
  end
end

Enumerable.class_eval do
  def average_seconds
    map {|_| _.parameters['seconds'].to_i }.sum / size
  end
end
