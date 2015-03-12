module Mailboxable
  def mailbox
    @mailbox ||= Mailbox.where( email_address:to ).first
  end
  
  private
  
  def to
    email.to.map {|_| _.fetch :email }
  end
  
  def from
    email.from[:email]
  end
  
  def recipients
    [ email.to, email.cc ].flatten.map {|_| _.fetch :email }
  end
end
