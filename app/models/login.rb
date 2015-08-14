class Login < ActiveRecord::Base
  belongs_to :team
  validates :email, presence:true, format:{ with: /\A[^@]+@[^@]+\z/ }
  validate :agent_present?, unless: :signup?
  after_create :generate_token

  private

  def agent_present?
    return true if Agent.where(email_address:email).any?
    errors[:email] << "agent email address not found"
  end
  
  def generate_token
    update token:Base64.urlsafe_encode64( \
      [id, SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz') ].join '-' )
  end
end
