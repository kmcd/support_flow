require 'elasticsearch/dsl'

module Searchable
  include Elasticsearch::DSL
  FACET_REGEX = /\w+:\w+/

  def initialize(text, team, page=1)
    @text, @team = text, team
    @page = page || 1
  end

  private
  
  def extract_full_text
    @text.split(/\s+/).reject {|_| _ =~ FACET_REGEX }.join ' '
  end

  def facet(field)
    return {} unless facets.has_key? field
    { term: { field => facets[field] } }
  end
  
  def facets
    return {} if @text.blank?
    Hash[ *extract_facets ]
  end
  
  def sort_order
    # TODO: find a more elegant solution rather than AND chaining
    facet('sort') && \
      facet('sort')[:term] && \
      facet('sort')[:term]['sort']
  end
  
  def extract_label_facets
    @text.scan(FACET_REGEX).grep(/label:/).
      map {|facet| { term: { 'labels' => facet[/\w+$/] } } }
  end
  
  def extract_facets
    @text.scan(FACET_REGEX).map {|_| _.split(':') }.flatten
  end
end