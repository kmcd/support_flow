# TODO: rename to RequestSearch
class AgentSearch
  attr_reader :query, :team

  def initialize(query, team, options={})
    @query, @team = query, team
  end

  def results
    Request.
      where(team:team).
      search_name_labels_emails(text_query).
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

  # TODO: index name, labels, emails, status, agent, labels
  # TODO: replace joins with materialized view
  # TODO: add (customer,agent) -> name, email
  Request.class_eval do
    scope :search_name_labels_emails, ->(query) {
      if query.present?
        joins(:emails).
          advanced_search( {name:query, labels:query, emails:{payload:query}}, false )
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
      when /emails/   ; order(emails_count:'desc')
      when /updated/  ; order(updated_at:'desc')
      end if order
    }
  end
end