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
  end

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

  def self.create_guide(guide, agent)
    create trackable:guide, owner:agent, key:'guide.create'
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

  def email
    Email::Inbound.find_by_id parameters['email_id']
  end
end
