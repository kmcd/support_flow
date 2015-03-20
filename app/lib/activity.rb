class Activity
  attr_reader :request, :agent
  
  def initialize(request:, agent:)
    @request, @agent = request, agent
  end
  
  def tag(tags)
    request.create_activity :tag, owner:agent, params:{tags:tags}
  end
  
  def assign(assignee=nil)
    agent_id = assignee && assignee.id
    request.create_activity :assign, owner:agent, params:{agent_id:agent_id}
  end
end