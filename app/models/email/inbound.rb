class Email::Inbound < Email
  validates :team, presence:true
  validates :payload, presence:true
  composed_of :message, mapping: %w[ payload ]

  def agent
    return unless from_agent?
    sender
  end

  def from_agent?
    team.agents.map(&:email_address).include? message.from
  end
  
  def addressed_to_request
    Request.find_by_id message.request_id
  end
end
