class Session < ActiveRecord::Base
  validates :email, presence:true, uniqueness:true, \
    format:{ with: /\A[^@]+@[^@]+\z/ }
  
  def generate_token
    update token:Base64.urlsafe_encode64( \
      [id, SecureRandom.urlsafe_base64(15).tr('lIO0', 'sxyz') ].join '-' )
  end
end
