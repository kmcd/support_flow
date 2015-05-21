class StatisticsJob < ActiveJob::Base
  queue_as :default

  # TODO: schedule job to run every 5 mins.
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
    team_activities :reply_time do |team, activities|
      stat = Statistic::Reply.where(owner:team).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end
  
  def team_close
    team_activities :close_time do |team, activities|
      stat = Statistic::Close.where(owner:team).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end
  
  def agent_reply
    agent_activities :reply_time do |agent, activities|
      stat = Statistic::Reply.where(owner:agent).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end
  
  def agent_close
    agent_activities :close_time do |agent, activities|
      stat = Statistic::Close.where(owner:agent).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end
  
  def customer_reply
    customer_activities :reply_time do |customer, activities|
      stat = Statistic::Reply.where(owner:customer).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end
  
  def customer_close
    customer_activities :close_time do |customer, activities|
      stat = Statistic::Close.where(owner:customer).first_or_initialize
      stat.value = average_time(activities)
      stat.save!
    end
  end
  
  def team_activities(activity_key)
    Team.all.each do |team|
      request_ids = team.requests.map &:id
      
      activities = PublicActivity::Activity.where \
        key:"request.#{activity_key.to_s}",
        trackable_id:request_ids,
        trackable_type:'Request'
        
      next if activities.empty?
      yield team, activities
    end
  end
  
  def agent_activities(activity_key)
    Agent.all.each do |agent|
      activities = PublicActivity::Activity.where \
        key:"request.#{activity_key.to_s}",
        owner:agent
        
      next if activities.empty?
      yield agent, activities
    end
  end
  
  def customer_activities(activity_key)
    Customer.all.each do |customer|
      activities = PublicActivity::Activity.where \
        key:"request.#{activity_key.to_s}",
        recipient:customer
        
      next if activities.empty?
      yield customer, activities
    end
  end
  
  def average_time(activities)
    activities.map {|_| _.parameters[:time].to_i }.sum / activities.size
  end
end
