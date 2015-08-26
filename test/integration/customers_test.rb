require 'test_helper'

class CustomersTest < ActionDispatch::IntegrationTest
  test "create from first enquiry" do
    flunk
  end
  
  test "create from reply" do
    flunk
    @new_customer_reply.process_payload

    assert_equal "new_customer@example.com", @new_customer_reply.sender.
      email_address
    assert_equal @peldi, @billing_enquiry.customer
  end
  
  test "associate existing customer when request customer blank" do
    flunk
    @billing_enquiry.update customer:nil
    @existing_customer_reply.process_payload
    assert_equal @peldi, @billing_enquiry.reload.customer
  end

  test "associate existing customer when request customer present" do
    flunk
    @billing_enquiry.update customer:@tobi
    @existing_customer_reply.process_payload

    assert_equal @tobi, @billing_enquiry.reload.customer
    assert_equal @peldi, @existing_customer_reply.sender
  end
  
  test "customer first reply" do
    flunk
    # reply to
    # ensure first reply time calculation correct
  end
  
  test "customer happiness" do
    flunk
    # reply to 
    # ensure first reply time calculation correct
  end
  
  test "customer average close" do
    flunk
    # reply to 
    # ensure first reply time calculation correct
  end
end
