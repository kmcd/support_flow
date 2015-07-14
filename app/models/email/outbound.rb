class Email::Outbound < Email
  accepts_nested_attributes_for :attachments, allow_destroy:true
  validates :recipients, presence:true
  validates :message_content, presence:true
  validate  :recipient_list_format
  validate  :attachments_under_size_limit
  composed_of :recipient_list, mapping:%w[ recipients ]

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
end
