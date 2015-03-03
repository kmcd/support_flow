class Mailbox < ActiveRecord::Base
  belongs_to :team
  has_many :messages
  
  # TODO: validate email_address
  # TODO: validate credentials
end
