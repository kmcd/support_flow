class Login < ActiveRecord::Base
  belongs_to :team
  validates :email_address, presence:true, format:{ with: /\A[^@]+@[^@]+\z/ }
  validate :agent_present?, unless: :signup?

  private

  def agent_present?
    return true if Agent.where(email_address:email_address).any?

    errors[:email_address] << "agent email address not found"
  end
end
