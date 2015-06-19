class CustomerSearch
  include Searchable

  def customers
    Customer.search(definition).page(@page).records
  end

  private

  def definition
    full_text       = extract_full_text
    team_facet      = { term: { team_id:@team.id } }
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
                  company
                  phone
                  email_address
                ]
              end
            end
          end

          filter do
            _and filters:[ team_facet ]
          end
        end
      end
    end
  end
end