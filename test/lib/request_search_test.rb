require 'test_helper'

class RequestSearchTest < ActiveSupport::TestCase
  def search(query)
    RequestSearch.new(query).records
  end

  cassette 'indexed_request_fixtures' do
    test "scoped by team" do
      skip
    end
  
    test "name" do
      skip
    end
  
    test "open" do
      skip
    end
  
    test "labels" do
      skip
    end
  
    test "agent" do
      skip
      # name, id
    end
  
    test "customer" do
      skip
      # name, id
    end
  
    test "company" do
      skip
    end
  
    test "sort by oldest" do
      skip
    end
  
    test "sort by newest" do
      skip
    end
  
    test "sort by recenctly updated" do
      skip
    end
  
    test "sort by most active" do
      skip
    end
  end
end
end
