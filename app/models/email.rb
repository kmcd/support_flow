class Email < ActiveRecord::Base
  belongs_to :request
  composed_of :message, mapping: %w[ payload ]
  delegate *%i[ to from subject text command_arguments ], to: :message
  
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
