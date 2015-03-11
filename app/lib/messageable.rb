module Messageable
  attr_reader :message
  
  def initialize(message)
    @message = message
  end
  
  def email
    message.content # TODO: delegate email to message
  end
  
  def to
    email.to.map {|_| _.fetch :email }
  end
  
  def from
    email.from.fetch :email
  end
  
  def cc
    email.cc.map {|_| _.fetch :email }
  end
  
  def recipients
    [to, cc].flatten
  end
end
