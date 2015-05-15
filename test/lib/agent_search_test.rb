require 'test_helper'

def agent_search(query=nil)
  AgentSearch.new(query, @support_flow).results
end

class AgentSearchTest < ActiveSupport::TestCase
  test "blank query returns all results" do
    assert_equal Request.all, agent_search('')
    assert_equal Request.all, agent_search(nil)
  end
  
  test "full text on request name" do
    @billing_enquiry.update name:'peldis card expiry'
    results = agent_search 'card expiry'
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "full text on labels" do
    @billing_enquiry.update label:'urgent'
    results = agent_search 'urgent'
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry.labels, results.first.labels
  end
  
  test "full text on message subject" do
    @billing_enquiry.messages.first.update subject:'please'
    results = agent_search 'please'
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "full text on message body" do
    @billing_enquiry.messages.first.update text_body:'in progress'
    results = agent_search 'in progress'
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
end

class AgentSearchFacetTest < ActiveSupport::TestCase
  test "open status" do
    @duplicate_enquiry.delete
    results = agent_search "billing is:open"
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "assigned agent" do
    results = agent_search "agent:#{@rachel.id}"
    
    assert_equal Request.where(agent:@rachel), results
  end
  
  test "customer" do
    Request.update_all "customer_id = 1"
    results = agent_search "customer:#{@peldi.id}"
    assert_empty results
    
    Request.update_all "customer_id = #{@peldi.id}"
    results = agent_search "customer:#{@peldi.id}"
    assert_equal [@peldi.id], results.map(&:customer_id).uniq
  end
  
  test "one label" do
    @billing_enquiry.update label:'billing'
    results = agent_search "label:billing"
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "multiple labels" do
    @billing_enquiry.update label:'billing'
    @billing_enquiry.update label:'urgent'
    results = agent_search "label:billing label:urgent"
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "combined facets and text query" do
    @billing_enquiry.update label:'billing', name:'expiry'
    @billing_enquiry.update label:'urgent'
    results = agent_search \
      "expiry is:open label:billing label:urgent agent:#{@rachel.id}"
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
end

class AgentSearchSortTest < ActiveSupport::TestCase
  def setup
    @billing_enquiry.update created_at:2.days.ago
    @duplicate_enquiry.update created_at:1.day.ago
    [ @billing_enquiry, @duplicate_enquiry ].each &:reload
  end
  
  test "sort by newest descending" do
    results = agent_search "billing enquiry sort:new"
    assert_equal [@duplicate_enquiry, @billing_enquiry], results
  end
  
  test "sort by oldest descending" do
    results = agent_search "billing enquiry sort:old"
    assert_equal [@billing_enquiry, @duplicate_enquiry], results
  end
  
  test "sort by messages" do
    Request.update_counters @billing_enquiry.id, messages_count:10
    results = agent_search "billing enquiry sort:messages"
    
    assert_equal [@billing_enquiry, @duplicate_enquiry], results
  end
  
  test "sort by recently updated" do
    @duplicate_enquiry.touch :updated_at
    results = agent_search "billing enquiry sort:updated"
    assert_equal [@duplicate_enquiry, @billing_enquiry], results
  end
end
