class AgentSearch
  attr_reader :query
  
  def initialize(query, agent=Agent.new, options={})
    @query = query
  end
  
  def results
    Request.
      search_name_labels_messages(text_query).
      status(status_facet).
      agent(agent_facet).
      label(label_facet).
      sort_order(sort_facet)
  end
  
  private
  
  def text_query
    [ query.split(/\s/) - facets ].join ' '
  end
  
  def status_facet
    return unless facet :is
    facet(:is)[/\open/] ? true : false
  end
  
  def agent_facet
    return unless facet :agent
    facet(:agent)[/\d+/]
  end
  
  def label_facet
    return unless facet :label
    facets.grep(/label/).map {|_| _.match(/:(\w+)/).captures.first }
  end
  
  def sort_facet
    return unless facet :sort
    facet(:sort).match(/:(\w+)/).captures.first
  end
  
  def facet(name)
    facets.grep(/#{name.to_s}/).first
  end
  
  def facets
    query.scan /\w+:\w+/
  end
  
  Request.class_eval do
    scope :search_name_labels_messages, ->(query) {
      joins(:messages).
      basic_search(
        { name:query, labels:query, messages:{ content:query } }, false ).
      distinct unless query.blank?
    }
    
    scope :status, ->(status) { 
      where(open:status) if status 
    }
    
    scope :agent, ->(agent_id) { 
      where(agent_id:agent_id) if agent_id 
    }
    
    scope :label, ->(labels) {
      where("requests.labels @> ARRAY[?]", labels) if labels
    }
    
    scope :sort_order, ->(order) {
      case order
      when /new/      ; order(created_at:'desc')
      when /old/      ; order(created_at:'asc')
      when /messages/ ; order(messages_count:'desc')
      when /updated/  ; order(updated_at:'desc')
      end if order
    }
  end
end