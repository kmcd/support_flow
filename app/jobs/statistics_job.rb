class StatisticsJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    team_reply
    team_close
    agent_reply
    agent_close
    customer_reply
    customer_close
  end

  private

  def team_reply
    Activity.teams :reply_time do |team, activities|
      stat = Statistic::Reply.where(owner:team).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end

  def team_close
    Activity.teams :close do |team, activities|
      stat = Statistic::Close.where(owner:team).order('id DESC').
        first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end

  def agent_reply
    Activity.agents :reply_time do |agent, activities|
      stat = Statistic::Reply.where(owner:agent).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end

  def agent_close
    Activity.agents :close do |agent, activities|
      stat = Statistic::Close.where(owner:agent).order('id DESC').
        first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end

  def customer_reply
    Activity.customers :reply_time do |customer, activities|
      stat = Statistic::Reply.where(owner:customer).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end

  def customer_close
    Activity.customers :close do |customer, activities|
      stat = Statistic::Close.where(owner:customer).order('id DESC').first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end

  def average_time(activities)
    activities.map {|_| _.parameters['seconds'].to_i }.sum / activities.size
  end
end

Activity.class_eval do
  def self.teams(activity_key)
    Team.all.each do |team|
      request_ids = team.requests.map &:id

      activities = Activity.where \
        key:"request.#{activity_key.to_s}",
        trackable_id:request_ids,
        trackable_type:'Request'

      next if activities.empty?
      yield team, activities
    end
  end

  def self.agents(activity_key)
    Agent.all.each do |agent|
      activities = Activity.where \
        key:"request.#{activity_key.to_s}",
        owner:agent

      next if activities.empty?
      yield agent, activities
    end
  end

  def self.customers(activity_key)
    Customer.all.each do |customer|
      activities = Activity.where \
        key:"request.#{activity_key.to_s}",
        recipient:customer

      next if activities.empty?
      yield customer, activities
    end
  end
end
