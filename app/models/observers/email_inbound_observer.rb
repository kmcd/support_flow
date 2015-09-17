class EmailInboundObserver < ActiveRecord::Observer
  observe Email::Inbound

  def before_validation(email)
    email.set_team
    email.set_recipients
  end

  def after_create(email)
    email.associate_request
    email.associate_agent
    email.associate_customer
    email.extract_attachments
    email.create_enquiry_activity
    email.create_first_reply_activity
    email.create_reply_activity
    email.process_commands
  end
end

Email::Inbound.class_eval do
  delegate :from, :subject, to: :message

  def set_team
    self.team = addressed_to_team || team_from_addressed_to_request
  end

  def set_recipients
    self.recipients = message.recipient_addresses.join ' '
  end

  def associate_request
    request = addressed_to_request || \
      create_request(team:team, name:subject, emails_count:1)

    update request:request
  end

  def associate_agent
    return unless from_agent?

    agent = Agent.where(email_address:from, team:team).first
    update sender:agent
  end

  def associate_customer
    return if from_agent?

    customer = existing_customer || create_customer
    request.update(customer:customer) if request.customer.blank?
    update sender:customer
  end

  # FIXME: remove binary content from log files
  # FIXME: remove dulicated binary content from payload ?
  # TODO: remove attachments table & store binary attachments in json?
  # (i.e. make attachments consistent with inbound email messages)
  # e.g. replace table with conditional, select association
  # has_many :attachments, select: :payload ...
  # Or is this ~too~ clever ?
  def extract_attachments
    return unless payload['msg'].has_key? 'attachments'

    payload['msg']['attachments'].each do |name,file|
      team.attachments.create \
        email:self,
        name:file['name'],
        content_type:file['type'],
        content:file['content'],
        base64:file['base64']
    end
  end

  def create_enquiry_activity
    return unless request.enquiry?

    request.create_activity :open, owner:sender,
      parameters:{ 'email_id' => id }
  end

  def create_first_reply_activity
    return unless first_reply?

    Activity.create \
      key:'request.reply_time',
      team:team,
      trackable:request,
      owner:sender,
      recipient:request.customer,
      parameters:{ 'seconds' => time_to_reply }
  end

  def create_reply_activity
    return unless message.request_reply?
    return if only_commands_present?

    Activity.create \
      key:'request.reply',
      team:team,
      trackable:request,
      owner:sender,
      recipient:request.customer,
      parameters:{ 'email_id' => id }
      # TODO: add reply time:
  end

  def process_commands
    return unless from_agent?
    return unless message.command_arguments.present?

    Command.new(self).execute
  end

  private

  def existing_customer
    Customer.where(email_address:from, team:team).first
  end

  def create_customer
    Customer.create email_address:from, name:from, team:team
  end

  def addressed_to_team
    if message.team_id
      Team.find_by_id message.team_id
    else
      Team.where(name:message.team_name).first
    end
  end

  def team_from_addressed_to_request
    return unless addressed_to_request.present?

    addressed_to_request.team
  end

  def first_reply?
    return unless from_agent?
    return unless to_customer?

    ! Activity.exists?(trackable:request, key:'request.reply_time')
  end

  def to_customer?
    return unless request.present?
    return unless request.customer.present?

    message.recipient_addresses.include? request.customer.email_address
  end

  def time_to_reply
    (0.seconds.ago - request.created_at).to_i
  end

  def only_commands_present?
    return unless message.command_arguments.present?
    [ message.text,  message.command_arguments ].uniq.one?
  end
end

Request.class_eval do
  def enquiry?
    Activity.where(key:'request.open', trackable:self).empty?
  end
end
