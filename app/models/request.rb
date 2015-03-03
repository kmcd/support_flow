class Request < ActiveRecord::Base
  belongs_to :mailbox
  belongs_to :agent
  belongs_to :customer
end
