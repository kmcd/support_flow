# OPTIMIZE: for clarity
# TODO: dry up owner/recipient setting
class Activity
  attr_reader :request, :owner, :recipient
  
  def initialize(request:, owner:nil, recipient:nil)
    @request, @owner, @recipient = request, owner, recipient
  end
  
  def self.create(request,owner,recipient=nil)
    activity = new request:request, owner:owner, recipient:recipient
    
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
    request.create_activity :label, owner:owner,recipient:recipient, 
      params:{labels:labels}
  end
  
  def assign(assignee=nil)
    agent_id = assignee && assignee.id
    request.create_activity :assign, owner:owner, recipient:recipient,
      params:{agent_id:agent_id}
  end
  
  def enquiry(message)
    request.create_activity :open, owner:owner, recipient:recipient,
      params:{email_id:message.id}
  end
  
  def reply(message)
    request.create_activity :reply, owner:owner, recipient:recipient,
      params:{email_id:message.id}
  end
  
  def open
    request.create_activity :open, owner:owner, recipient:recipient
  end
  
  def close
    request.create_activity :close, owner:owner, recipient:recipient
  end
  
  def rename(to)
    request.create_activity :rename, owner:owner, recipient:recipient,
      params:{name:to}
  end
  
  def merge(merged_request)
    request.create_activity :merge, owner:owner, recipient:recipient,
      params:{request_id:merged_request.id, request_name:merged_request.name}
  end
  
  def first_reply_time
    return unless open = request.activities.where(key:'request.open').first
    request.create_activity :first_reply, owner:owner, recipient:recipient,
      params:{seconds:(Time.now - open.created_at.to_time).to_i}
  end
end