class RequestSearch
  include Searchable

  def requests
    Request.
      search(definition).
      page(@page).
      records
  end

  private

  def definition
    # TODO: investigate elasticsearch dsl scoping
    full_text       = extract_full_text
    team_facet      = { term: { team_id:@team.id } }
    open_facet      = facet 'open'
    customer_facet  = facet 'customer_id'
    agent_facet     = facet 'agent_id'
    label_facets    = extract_label_facets
    sort_by         = sort_order

    search do
      query do
        filtered do

          if full_text.present?
            query do
              multi_match do
                query full_text
                fields %w[
                  name
                  labels
                  agent.name
                  customer.name
                  customer.company
                  emails.text
                ]
              end
            end
          end

          filter do
            and_filters = [
              team_facet,
              open_facet,
              customer_facet,
              agent_facet
            ]
            and_filters.push(label_facets) unless label_facets.empty?
            _and filters:and_filters
          end
        end
      end

      sort do
        case sort_by
          when /new/i     ; by(:created_at,   order: 'desc')
          when /old/i     ; by(:created_at,   order: 'asc')
          when /updated/i ; by(:updated_at,   order: 'desc')
          when /active/i  ; by(:emails_count, order: 'desc')
        end
      end
    end
  end
end