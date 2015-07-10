class Email::Inbound < Email
  validates :payload, presence:true
  composed_of :message, mapping: %w[ payload ]
  delegate *%i[ to from subject text command_arguments ], to: :message

  def self.create_from(mandrill_payload)
    # Must perform_now to handle attachments - uploaded tmpfiles are not
    # available accross web processes or background workers
    InboundEmailJob.perform_now mandrill_payload
  end

  def agent
    return unless request && request.team
    request.team.agents.where(email_address:from).first
  end

  def associate_request
    return if request.present?
    return if message.request_id.blank?
    update request:Request.find_by_id(message.request_id)
  end
end
