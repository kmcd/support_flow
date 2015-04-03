class AgentSearch
  attr_reader :query
  
  def initialize(query)
    @query = query
  end
  
  def results
    RequestDocument.search(query).results
  end
end