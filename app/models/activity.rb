class Activity < ActiveRecord::Base
  belongs_to :team

  with_options polymorphic:true do |activity|
    activity.belongs_to :owner
    activity.belongs_to :recipient
    activity.belongs_to :trackable
  end

  def self.enquiry(email)
    create \
      key:'request.open',
      team:email.team,
      trackable:email.request,
      owner:email.request.customer,
      parameters:{ 'email_id' => email.id }
  end

  def self.reply(email)
    create \
      key:'request.reply',
      team:email.team,
      trackable:email.request,
      owner:email.sender,
      recipient:email.request.customer,
      parameters:{ 'email_id' => email.id }
      # TODO: add reply time:
  end

  # TODO: move to reply
  def self.first_reply_time(email)
    time_to_reply = (0.seconds.ago - email.request.created_at).to_i

    create \
      key:'request.first_reply',
      team:email.team,
      trackable:email.request,
      owner:email.sender,
      recipient:email.request.customer,
      parameters:{ 'seconds' => time_to_reply }
  end

  def self.assign(request, agent)
    create \
      key:'request.assign',
      trackable:request,
      owner:agent,
      recipient:request.agent
  end

  def self.open(request, agent)
    create \
      key:'request.open',
      trackable:request,
      owner:agent
  end

  def self.close(request, agent)
    create \
      key:'request.close',
      trackable:request,
      owner:agent
  end

  def self.label(request, agent, labels)
    create \
      key:'request.label',
      trackable:request,
      owner:agent,
      parameters:{ labels:labels.join(' ') }
  end

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

  def email
    Email::Inbound.find_by_id parameters['email_id']
  end
end
