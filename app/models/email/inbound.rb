class Email::Inbound < Email
  before_validation :set_team
  validates :payload, presence:true
  validates :team, presence:true
  composed_of :message, mapping: %w[ payload ]

  def process_payload
    return unless valid?
    set_recipients
    associate_request
    associate_agent
    associate_customer
    extract_attachments
    process_enquiry
    process_first_reply
    process_reply
    process_commands
  end

  def agent
    sender if from_agent?
  end

  private

  def set_team
    self.team = addressed_to_team || team_from_regarding_request
  end

  def set_recipients
    update recipients:message.recipient_addresses.join(' ')
  end

  def associate_request
    email_request = if message.request_id.blank?
      create_request team:team, name:message.subject
    else
      regarding_request
    end

    update request:email_request
    request.increment! :emails_count
  end

  def associate_agent
    return unless from_agent?

    update sender:team.agents.where(email_address:message.from).first
  end

  def associate_customer
    return if from_agent?

    customer = existing_customer || new_customer

    if request.customer.blank?
      request.update customer:customer
    else
      update sender:customer
    end
  end


  def existing_customer
    team.customers.where(email_address:message.from).first
  end

  def new_customer
    # TODO: extract name from email address
    team.customers.create email_address:message.from, name:message.from
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

  def process_enquiry
    return if request_reply? || team.blank?

    Activity.enquiry self
  end

  def process_first_reply
    return unless from_agent?
    return unless to_customer?
    return if Activity.exists?(trackable:request, key:'request.reply_time')

    Activity.first_reply_time self
  end

  def process_reply
    return unless request_reply?
    return if only_commands_present?

    Activity.reply self
  end

  def request_reply?
    message.request_id.present?
  end

  def process_commands
    return unless from_agent?
    return unless message.command_arguments.present?

    Command.new(self).execute
  end

  def from_agent?
    team.agents.map(&:email_address).include? message.from
  end

  def to_customer?
    return unless request.present?
    return unless request.customer.present?

    message.recipient_addresses.include? request.customer.email_address
  end

  def regarding_request
    Request.find_by_id message.request_id
  end

  def addressed_to_team
    Team.find_by_id message.team_id
  end

  def team_from_regarding_request
    return unless regarding_request.present?
    regarding_request.team
  end

  def only_commands_present?
    return unless message.command_arguments.present?
    [ message.text,  message.command_arguments ].uniq.one?
  end
end

Activity.class_eval do
  # TODO: merge with Activity.reply
  def self.first_reply_time(email)
    time_to_reply = (0.seconds.ago - email.request.created_at).to_i

    create \
      key:'request.reply_time',
      team:email.team,
      trackable:email.request,
      owner:email.sender,
      recipient:email.request.customer,
      parameters:{ 'seconds' => time_to_reply }
  end
end
