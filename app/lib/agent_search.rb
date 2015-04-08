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
      customer(customer_facet).
      label(label_facet).
      sort_order(sort_facet).
      to_a.uniq &:id
  end
  
  private
  
  def text_query
    return if query.blank?
    [ query.split(/\s/) - facets ].join ' '
  end
  
  def status_facet
    return unless facet :is
    facet(:is)[/open/] ? true : false
  end
  
  def agent_facet
    return unless facet :agent
    facet(:agent)[/\d+/]
  end
  
  def customer_facet
    return unless facet :customer
    facet(:customer)[/\d+/]
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
    return [] if query.blank?
    query.scan /\w+:\w+/
  end
  
  # TODO: index name, labels, messages, status, agent, labels
  # TODO: replace joins with materialized view
  Request.class_eval do
    scope :search_name_labels_messages, ->(query) {
      if query.present?
        joins(:messages).
        basic_search( { name:query, labels:query,
          # TODO: add (customer,agent) -> name, email
          messages:{ subject:query, text_body:query } }, false )
      end
    }
    
    scope :status, ->(status) { 
      where(open:status) unless status.nil?
    }
    
    scope :agent, ->(agent_id) { 
      where(agent_id:agent_id) if agent_id 
    }
    
    scope :customer, ->(customer_id) { 
      where(customer_id:customer_id) if customer_id 
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