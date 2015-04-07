require 'test_helper'

class AgentSearchTest < ActiveSupport::TestCase
  test "blank query returns all results" do
    assert_equal Request.all, AgentSearch.new('').results
    assert_equal Request.all, AgentSearch.new(nil).results
  end
  
  test "full text on request name" do
    @billing_enquiry.update name:'peldis card expiry'
    results = AgentSearch.new('card expiry').results
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "full text on labels" do
    @billing_enquiry.update label:'urgent'
    results = AgentSearch.new('urgent').results
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry.labels, results.first.labels
  end
  
  test "full text on message subject" do
    @billing_enquiry.messages.first.update subject:'please'
    results = AgentSearch.new('please').results
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "full text on message body" do
    @billing_enquiry.messages.first.update text_body:'in progress'
    results = AgentSearch.new('in progress').results
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
end

class AgentSearchFacetTest < ActiveSupport::TestCase
  test "open status" do
    @duplicate_enquiry.delete
    results = AgentSearch.new("billing is:open").results
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "assigned agent" do
    results = AgentSearch.new("agent:#{@rachel.id}").results
    
    assert_equal Request.where(agent:@rachel), results
  end
  
  test "one label" do
    @billing_enquiry.update label:'billing'
    results = AgentSearch.new("label:billing").results
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "multiple labels" do
    @billing_enquiry.update label:'billing'
    @billing_enquiry.update label:'urgent'
    results = AgentSearch.new("label:billing label:urgent").results
    
    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end
  
  test "combined facets and text query" do
    @billing_enquiry.update label:'billing', name:'expiry'
    @billing_enquiry.update label:'urgent'
    results = AgentSearch.new(
      "expiry is:open label:billing label:urgent agent:#{@rachel.id}"
    ).results
    
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
    results = AgentSearch.new("billing enquiry sort:new").results
    assert_equal [@duplicate_enquiry, @billing_enquiry], results
  end
  
  test "sort by oldest descending" do
    results = AgentSearch.new("billing enquiry sort:old").results
    assert_equal [@billing_enquiry, @duplicate_enquiry], results
  end
  
  test "sort by messages" do
    Request.update_counters @billing_enquiry.id, messages_count:10
    results = AgentSearch.new("billing enquiry sort:messages").results
    
    assert_equal [@billing_enquiry, @duplicate_enquiry], results
  end
  
  test "sort by recently updated" do
    @duplicate_enquiry.touch :updated_at
    results = AgentSearch.new("billing enquiry sort:updated").results
    assert_equal [@duplicate_enquiry, @billing_enquiry], results
  end
end
