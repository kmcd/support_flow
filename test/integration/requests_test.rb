require 'test_helper'

class RequestsTest < ActionDispatch::IntegrationTest
  test "inbound email enquiry" do
    skip
    # set agent
    # set team
    # set customer
  end
  
  test "inbound email reply" do
    skip
    @command.process_payload

    assert_equal @billing_enquiry, @command.reload.request
  end
  
  test "outbound reply" do
    skip
    # dispatch reply
    # add attachments
    # cc request address
  end
  
  test "outbound demo reply" do
    skip
    # email sender instead of recipients
  end
  
  test "request waiting time" do
    skip
    # time passes
    # ensure request waiting time up to date
  end
  
  test "request first reply" do
    skip
    # reply to request
    # ensure first reply time calculation correct
  end
  
  test "canned response" do
    skip
  end
end

class RequestSearchTest < ActionDispatch::IntegrationTest
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

  test "sort by recently updated" do
    skip
  end

  test "sort by most active" do
    skip
  end
end
