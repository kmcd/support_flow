# TODO: extract functionality & remove (mailboxes not needed)
module Mailboxable
  delegate :email, to: :message
  delegate *%i[ recipient_addresses from ], to: :email
  
  def mailbox
    @mailbox ||= \
      request_mailbox || \
      addressed_to_mailbox || \
      request_address_mailbox
  end
  
  private
  
  def request_mailbox
    return unless request
    Mailbox.
      joins(:messages).
      where('messages.request_id' => request.id).
      first
  end
  
  def addressed_to_mailbox
    # FIXME: ensure 1st address is sender
    Mailbox.where( email_address:recipient_addresses ).first
  end
    
  # TODO: move to email router; i.e. request.736 -> mailbox.438
  def request_address_mailbox
    return unless request_id
    team = Request.find(request_id)
    Mailbox.where(team_id:team.id).first
  end
  
  def request_id
    requests = recipient_addresses.grep /request\.\d+/
    return if requests.empty?
    requests.first.match(/request\.(\d+)/)[1]
  end
end
