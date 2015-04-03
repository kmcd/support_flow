require 'test_helper'

class AgentSearchTest < ActiveSupport::TestCase
  def vcr
    VCR.use_cassette('elastic_search', record: :new_episodes) { yield }
  end
  
  test "full text on request name" do
    vcr do
      results = AgentSearch.new('follow up').results
      
      assert_equal 1, results.size
      assert_equal @duplicate_enquiry.name, results.first.name
    end
  end
  
  test "full text on labels" do
    vcr do
      results = AgentSearch.new('urgent').results
      
      assert_equal 1, results.size
      assert_equal @billing_enquiry.labels, results.first.labels
    end
  end
  
  test "full text on message subject" do
    vcr do
      results = AgentSearch.new('Help').results
      
      assert_equal 1, results.size
      
      assert_equal @billing_enquiry.id.to_s, results.first.id.to_s
    end
  end
  
  test "full text on message content" do
    vcr do
      results = AgentSearch.new('on it Peldi').results
      
      assert_equal 1, results.size
      assert_equal @billing_enquiry.id.to_s, results.first.id.to_s
    end
  end
end

class AgentSearchFacetTest < ActiveSupport::TestCase
  test "status facet" do
    skip
  end
  
  test "agent facet" do
    skip
  end
  
  test "label facet" do
    skip
  end
end

class AgentSearchSortTest < ActiveSupport::TestCase
  test "sort by longest open" do
    skip
  end
  
  test "sort by newest" do
    skip
  end
  
  test "sort by most active" do
    skip
  end
end
