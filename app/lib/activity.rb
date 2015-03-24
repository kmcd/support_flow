class Activity
  attr_reader :request, :owner
  
  def initialize(request:, owner:nil)
    @request, @owner = request, owner
  end
  
  def self.create(request,owner)
    if agent_id = request.previous_changes[:agent_id].try(&:last)
      activity = new request:request,owner:owner
      activity.assign Agent.find(agent_id)
    end
  end
  
  def label(labels)
    request.create_activity :label, owner:owner, params:{labels:labels}
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