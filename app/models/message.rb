class Message
  attr_reader :payload
  delegate *%i[ subject html text attachments ], to: :payload
  
  def initialize(payload)
    @payload = OpenStruct.new payload['msg']
  end
  
  def to
    payload.email
  end
  
  def from
    payload.from_email
  end
  
  def recipients
    payload.to | payload.cc
  end
  
  def recipient_addresses
    recipients.map &:first
  end
end
