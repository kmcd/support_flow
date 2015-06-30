require 'test_helper'

class EnquiryJobTest < ActiveSupport::TestCase
  test "create new request" do
    skip
    assert_difference 'Request.count', 1 do
      EnquiryJob.perform_now(@enquiry)
      assert @enquiry.request.persisted?
    end
  end
  
  test "assign request to team" do
    skip
    EnquiryJob.perform_now(@enquiry)
    assert_equal @support_flow, @enquiry.request.team
  end
  
  test "increment request message counter" do
    skip
    EnquiryJob.perform_now(@enquiry)
    assert_equal 1, @enquiry.request.emails_count
  end
  
  test "create new customer" do
    skip
    assert_difference 'Customer.count', 1 do
      EnquiryJob.perform_now(@enquiry)
      customer = @enquiry.request.customer
      
      assert customer.persisted?
      assert_equal @enquiry.from, customer.email_address
    end
  end
  
  test "use existing customer account" do
    skip
    assert_difference 'Customer.count', 0 do
      EnquiryJob.perform_now(@existing_customer_enquiry)
      assert_equal @peldi, @existing_customer_enquiry.request.customer
    end
  end
  
  test "dont create new customer when email is from an agent" do
    skip
    EnquiryJob.perform_now(@agent_enquiry)
    assert_nil @agent_enquiry.request.customer
  end
  
  test "ignore non-existent mailboxes" do
    skip
    @enquiry.payload['msg']['email'] = 'foo@bar.com'
    EnquiryJob.perform_now(@enquiry)
    assert_nil @enquiry.request
  end
  
  test "ignore replies to existing requests" do
    skip
    assert_enquiry = -> () {
      EnquiryJob.perform_now(@enquiry)
      assert_nil @enquiry.request }
    
    @enquiry.payload['msg']['email'] = 'request.123@bar.com'
    assert_enquiry.call
    
    @enquiry.payload['msg']['to'] = [['request.123@bar.com', nil]]
    assert_enquiry.call
    
    @enquiry.payload['msg']['cc'] = [['request.123@bar.com', nil]]
    assert_enquiry.call
  end
  
  test "update activity stream" do
    skip
    EnquiryJob.perform_now(@existing_customer_enquiry)
    activity = @existing_customer_enquiry.request.activities.first
    
    assert_equal @peldi, activity.owner
    assert_equal 'request.open', activity.key
    
    assert_equal({email_id:@existing_customer_enquiry.id}, activity.parameters)
  end
end
