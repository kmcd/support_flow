require 'will_paginate/array'

class GuideSearch
  include Searchable
  
  def guides
    guide_search.records
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
                  content
                ]
              end
            end
          end

          filter do
            _and filters:[ team_facet ]
          end
        end
      end
      
      highlight fields: {
        name:     { fragment_size: 50 },
        content:  { fragment_size: 250 }
      }
    end
  end
  
  def guide_search
    Guide.search(definition).page @page
  end
end