class Message
  COMMAND_REGEX = /\A\s*-{1,2}\w+.*\Z/
  REQUEST_ID_REGEX = /request.(\d+)/
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
    return payload.to if payload.cc.blank?
    payload.to | payload.cc
  end
  
  def recipient_addresses
    recipients.map &:first
  end
  
  def command_arguments
    return if text.blank?
    text.split(/\\n/).find_all {|_| _[COMMAND_REGEX] }.join.strip
  end
  
  def request_id
    request_id_from_subject || request_id_from_recipients
  end
  
  private
  
  def request_id_from_subject
    subject_request = REQUEST_ID_REGEX.match subject
    subject_request && subject_request[1]
  end

  def request_id_from_recipients
    to_request = recipient_addresses.find {|_| REQUEST_ID_REGEX.match _ }
    to_request && REQUEST_ID_REGEX.match(to_request)[1]
  end
end
