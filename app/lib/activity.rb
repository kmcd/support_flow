class Activity
  attr_reader :request, :owner
  
  def initialize(request:, owner:nil)
    @request, @owner = request, owner
  end
  
  def self.create(request,owner)
    activity = new request:request, owner:owner
    
    if agent_id = request.previous_changes[:agent_id].try(&:last)
      activity.assign Agent.find(agent_id)
    end
    
    if labels = request.previous_changes[:labels].try(&:last)
      changes = request.previous_changes[:labels]
      new_labels = changes.last - changes.first
      activity.label new_labels
    end
    
    if new_name = request.previous_changes[:name].try(&:last)
      activity.rename new_name
    end
    
    if status_change = request.previous_changes[:open]
      status_change.last ? activity.open : activity.close
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
  
  def rename(to)
    request.create_activity :rename, owner:owner, params:{name:to}
  end
  
  def merge(merged_request)
    request.create_activity :merge, owner:owner,
      params:{request_id:merged_request.id, request_name:merged_request.name}
  end
end