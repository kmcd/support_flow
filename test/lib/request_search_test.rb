require 'test_helper'

def request_search(query=nil)
  RequestSearch.new(query, @support_flow).results
end

class RequestSearchTest < ActiveSupport::TestCase
  test "blank query returns all results" do
    assert_equal Request.all, request_search('')
    assert_equal Request.all, request_search(nil)
  end

  test "full text on request name" do
    @billing_enquiry.update name:'peldis card expiry'
    results = request_search @billing_enquiry.name

    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end

  test "full text on labels" do
    @billing_enquiry.update label:'urgent'
    results = request_search 'urgent'

    assert_equal 1, results.size
    assert_equal @billing_enquiry.labels, results.first.labels
  end

  test "full text on message subject" do
    @enquiry.update request:@billing_enquiry
    results = request_search @enquiry.text.strip

    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end

  test "full text on message body" do
    @billing_enquiry.emails.first.update text_body:'in progress'
    results = request_search 'in progress'

    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end

  test "open status" do
    @duplicate_enquiry.delete
    results = request_search "billing is:open"

    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end

  test "assigned agent" do
    results = request_search "agent:#{@rachel.id}"

    assert_equal Request.where(agent:@rachel), results
  end

  test "customer" do
    Request.update_all "customer_id = 1"
    results = request_search "customer:#{@peldi.id}"
    assert_empty results

    Request.update_all "customer_id = #{@peldi.id}"
    results = request_search "customer:#{@peldi.id}"
    assert_equal [@peldi.id], results.map(&:customer_id).uniq
  end

  test "one label" do
    @billing_enquiry.update label:'billing'
    results = request_search "label:billing"

    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end

  test "multiple labels" do
    @billing_enquiry.update label:'billing'
    @billing_enquiry.update label:'urgent'
    results = request_search "label:billing label:urgent"

    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end

  test "combined facets and text query" do
    @billing_enquiry.update label:'billing', name:'expiry'
    @billing_enquiry.update label:'urgent'
    results = request_search \
      "expiry is:open label:billing label:urgent agent:#{@rachel.id}"

    assert_equal 1, results.size
    assert_equal @billing_enquiry, results.first
  end

  def setup_sort
    @billing_enquiry.update created_at:2.days.ago
    @duplicate_enquiry.update created_at:1.day.ago
    [ @billing_enquiry, @duplicate_enquiry ].each &:reload
  end

  test "sort by newest descending" do
    results = request_search "billing enquiry sort:new"
    assert_equal [@duplicate_enquiry, @billing_enquiry], results
  end

  test "sort by oldest descending" do
    results = request_search "billing enquiry sort:old"
    assert_equal [@billing_enquiry, @duplicate_enquiry], results
  end

  test "sort by emails" do
    Request.update_counters @billing_enquiry.id, emails_count:10
    results = request_search "billing enquiry sort:emails"

    assert_equal [@billing_enquiry, @duplicate_enquiry], results
  end

  test "sort by recently updated" do
    @duplicate_enquiry.touch :updated_at
    results = request_search "billing enquiry sort:updated"
    assert_equal [@duplicate_enquiry, @billing_enquiry], results
  end
end
