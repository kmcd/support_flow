class Activity
  attr_reader :request, :owner
  
  def initialize(request:, owner:nil)
    @request, @owner = request, owner
  end
  
  def tag(tags)
    request.create_activity :tag, owner:owner, params:{tags:tags}
  end
  
  def assign(assignee=nil)
    agent_id = assignee && assignee.id
    request.create_activity :assign, owner:owner, params:{agent_id:agent_id}
  end
  
  def enquiry(message)
    request.create_activity :open, owner:owner, 
      params:{message_id:message.id}
  end
  
  def reply(message)
    request.create_activity :reply, owner:owner, 
      params:{message_id:message.id}
  end
  
  def open
    request.create_activity :open, owner:owner
  end
  
  def close
    request.create_activity :close, owner:owner
  end
end