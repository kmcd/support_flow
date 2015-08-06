class Login < ActiveRecord::Base
  validates :email, presence:true, uniqueness:true, \
    format:{ with: /\A[^@]+@[^@]+\z/ }

  validate :agent_present?

  def generate_token
    update token:Base64.urlsafe_encode64( \
      [id, SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz') ].join '-' )
  end

  private

  def agent_present?
    return if Agent.where(email_address:email).any?

    errors[:email] << "not found"
  end
end
