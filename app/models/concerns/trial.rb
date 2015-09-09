class Trial
  include ActiveModel::Model
  attr_accessor :team, :team_name
  validate :current_team

  def start
    return unless valid?

    team.trial!
    team.save!
    clear_demo_data
    create_trial_activity
  end

  def team_name
    team.name
  end

  def team_name=(name)
    team.name = name
  end

  private

  def current_team
    return if team.valid?

    errors[:team_name] << team.errors.full_messages
  end

  def clear_demo_data
    requests = team.requests.where("created_at <= ?", team.created_at)
    request_ids = requests.map &:id

    Activity.
      where(trackable_type:'Request', trackable_id:request_ids).
      destroy_all

    Email.where(request_id:request_ids).destroy_all

    requests.destroy_all

    customers = team.customers.
      where("email_address SIMILAR TO '%@example\.(com|net|org)%'")

    customer_ids = customers.map &:id

    Activity.
      where(trackable_type:'Customer', trackable_id:customer_ids).
      destroy_all

    Activity.
      where(recipient_type:'Customer', recipient_id:customer_ids).
      destroy_all

    Activity.
      where(owner_type:'Customer', owner_id:customer_ids).
      destroy_all

    customers.destroy_all

    team.emails.inbound.
      where("created_at <= ?", team.created_at).
      destroy_all

    agents = team.agents.
      where("email_address SIMILAR TO '%@example\.(com|net|org)%'")

    agent_ids = agents.map &:id

    Activity.
      where(trackable_type:'Agent', trackable_id:agent_ids).
      destroy_all

    Activity.
      where(recipient_type:'Agent', recipient_id:agent_ids).
      destroy_all

    Activity.
      where(owner_type:'Agent', owner_id:agent_ids).
      destroy_all

    lead_agent = team.agents.first
    [ agents - [ lead_agent  ] ].flatten.each &:destroy

    team.guides.each do |_|
      _.activities.create key:'guide.create', owner:lead_agent
    end

    Statistic::Reply.where(owner:team).first_or_initialize.update value:'0'
    Statistic::Close.where(owner:team).first_or_initialize.update value:'0'
  end

  def create_trial_activity
    payload = {
      "event": "inbound",
      "ts": Time.now.to_i,
      "msg": {
        "from_email": "rachel@getsupportflow.net",
        "from_name": "Rachel",
        "email": "team.#{team.id}@getsupportflow.net",
        "to": [ [ "team.#{team.id}@getsupportflow.net", nil ] ],
        "cc": [ [ nil, nil ] ],
        "subject": "Welcome",
        "text": "Welcome! \n\n",
        "html": "<p>Welcome!<p>"
      }
    }.to_json

    Email::Inbound.create payload:payload
  end
end