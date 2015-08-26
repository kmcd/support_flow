class Email::Outbound < Email
  accepts_nested_attributes_for :attachments, allow_destroy:true
  validates :recipients, presence:true
  validates :message_content, presence:true
  validate  :recipient_list_format
  validate  :attachments_under_size_limit
  validate  :sender_team_agent
  before_create :set_team

  def set_team
    return unless request.present? && team.blank?
    self.team = request.team
  end

  private

  def attachments_under_size_limit
    return if attachments.sum(&:size) < 25.megabytes

    errors.add :attachments, "must be under 25 megabytes"
  end

  def recipient_list_format
    return if recipient_list.valid?

    recipient_list.invalid.each do |email|
      errors.add :recipients, "#{email} is invalid"
    end
  end

  def sender_team_agent
    return if team.agents.include? sender

    errors.add :sender, "invalid team" # TODO: flag url hacking
  end
end
