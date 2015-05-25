class Command
  attr_reader :activity, :email
  delegate :request, :agent, to: :email
  
  def initialize(email)
    @email = email
    @activity = Activity.new request:request, owner:agent
  end
  
  def assign(name_or_email)
    request.assign_from name_or_email
    activity.assign request.agent
  end
  
  def claim
    request.update_attributes! agent:agent
    activity.assign agent
  end
  
  def close
    request.update_attributes! open:false
    activity.close
  end
  
  def open
    request.update_attributes! open:true
    activity.open
  end
  
  def release
    request.update_attributes! agent:nil
    activity.assign
  end
  
  def label(labels)
    request.update label:labels
    activity.label labels
  end
end