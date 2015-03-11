class Message < ActiveRecord::Base
  belongs_to :mailbox
  belongs_to :request
  belongs_to :agent
  belongs_to :customer
  serialize :content  # TODO: serialize as JSON
end
