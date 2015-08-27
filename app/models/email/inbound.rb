class Email::Inbound < Email
  validates :team, presence:true
  validates :payload, presence:true
  composed_of :message, mapping: %w[ payload ]

  def agent
    sender if sender.is_a?(Agent)
  end

  def from_agent?
    team.agents.map(&:email_address).include? message.from
  end

  def addressed_to_request
    Request.find_by_id message.request_id
  end
end
