require 'test_helper'

class CustomersTest < ActionDispatch::IntegrationTest
  test "create from first enquiry" do
    skip
  end
  
  test "create from reply" do
    skip
    @new_customer_reply.process_payload

    assert_equal "new_customer@example.com", @new_customer_reply.sender.
      email_address
    assert_equal @peldi, @billing_enquiry.customer
  end
  
  test "associate existing customer when request customer blank" do
    skip
    @billing_enquiry.update customer:nil
    @existing_customer_reply.process_payload
    assert_equal @peldi, @billing_enquiry.reload.customer
  end

  test "associate existing customer when request customer present" do
    skip
    @billing_enquiry.update customer:@tobi
    @existing_customer_reply.process_payload

    assert_equal @tobi, @billing_enquiry.reload.customer
    assert_equal @peldi, @existing_customer_reply.sender
  end
  
  test "customer first reply" do
    skip
    # reply to
    # ensure first reply time calculation correct
  end
  
  test "customer happiness" do
    skip
    # reply to 
    # ensure first reply time calculation correct
  end
  
  test "customer average close" do
    skip
    # reply to 
    # ensure first reply time calculation correct
  end
end

class CustomerSearchTest < ActionDispatch::IntegrationTest
  test "scoped by team" do
    skip
  end

  test "name" do
    skip
  end

  test "labels" do
    skip
  end

  test "open count" do
    skip
  end

  test "close count" do
    skip
  end

  test "company" do
    skip
  end

  test "phone" do
    skip
  end

  test "email" do
    skip
  end

  test "sort by open_count" do
    skip
  end

  test "sort by close_count" do
    skip
  end
end

