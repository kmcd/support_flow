class CustomerSearch
  include Searchable
  
  def records
    Customer.search(definition, size:RESULTS_PER_PAGE).records
  end
  
  private

  def definition
    full_text       = extract_full_text
    team_facet      = { term: { team_id:@team.id } }
    open_facet      = facet 'open'
    customer_facet  = facet 'customer_id'
    agent_facet     = facet 'agent_id'
    sort_by         = sort_order

    search do
      query do
        multi_match do
          query full_text
          fields %w[
            name
            labels
            agent_name
            customer_name
            customer_company
            emails_text
          ]
        end

        filtered do
          filter do
            _and filters:[
              team_facet,
              open_facet,
              customer_facet,
              agent_facet
            ]
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