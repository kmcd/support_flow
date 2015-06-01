require 'elasticsearch'

class RequestSearch
  attr_reader :query, :team

  def initialize(query, team, options={})
    @query, @team = query, team
  end

  def results
  end
  
  # facets
  # sorting
end

class RequestDocument
  # name
  # labels
  # messsages subject
  # messages body
  # status
  # assigned agent
  # customer
end