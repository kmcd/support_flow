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
    Activity.teams :close_time do |team, activities|
      stat = Statistic::Close.where(owner:team).first_or_initialize
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
    Activity.agents :close_time do |agent, activities|
      stat = Statistic::Close.where(owner:agent).first_or_initialize
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
    Activity.customers :close_time do |customer, activities|
      stat = Statistic::Close.where(owner:customer).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end

  def average_time(activities)
    activities.map {|_| _.parameters['time'].to_i }.sum / activities.size
  end
end
