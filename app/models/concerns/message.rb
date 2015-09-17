class Message
  APP_DOMAIN = 'getsupportflow.net' # TODO: move to config
  COMMAND_REGEX = /\A\s*-{1,2}\w+.*\Z/
  REQUEST_ID_REGEX = /request\.(\d+)@#{APP_DOMAIN}/
  TEAM_EMAIL_REGEX = /team\.(\d+)@#{APP_DOMAIN}/
  TEAM_NAME_EMAIL_REGEX = /(.*)@#{APP_DOMAIN}/

  attr_reader :payload, :email
  delegate *%i[ subject attachments ], to: :payload

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

  def html
    Griddler::EmailParser.extract_reply_body payload.html
  end

  def text
    Griddler::EmailParser.extract_reply_body payload.text
  end

  def command_arguments
    return if text.blank?
    text.split(/\\n/).find_all {|_| _[COMMAND_REGEX] }.join.strip
  end

  def request_id
    request_id_from_subject || request_id_from_recipients
  end

  def team_id
    return unless to && to.match(TEAM_EMAIL_REGEX)

    TEAM_EMAIL_REGEX.match(to)[1]
  end

  def team_name
    return unless to && to.match(TEAM_NAME_EMAIL_REGEX)

    TEAM_NAME_EMAIL_REGEX.match(to)[1]
  end

  def request_reply?
    request_id.present?
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
