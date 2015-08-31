require 'test_helper'

class CustomersTest < ActionDispatch::IntegrationTest
  test "create from first enquiry" do
    inbound @enquiry

    assert_equal @enquiry.payload['msg']['from_email'], Customer.last.email_address
  end

  test "create from reply" do
    inbound @new_customer_reply

    assert_equal @enquiry.payload['msg']['from_email'], Customer.last.email_address
    assert_equal @peldi, @billing_enquiry.customer
  end

  test "associate existing customer when request customer blank" do
    @billing_enquiry.update customer:nil
    inbound @existing_customer_reply

    assert_equal @peldi, @billing_enquiry.reload.customer
  end

  test "associate existing customer when request customer present" do
    @billing_enquiry.update customer:@tobi
    inbound @existing_customer_reply

    assert_equal @tobi, @billing_enquiry.reload.customer
    assert_equal @peldi, Email::Inbound.last.sender
  end

  test "customer first reply" do
    opened_at = 10.days.ago.at_beginning_of_day
    @billing_enquiry.update created_at:opened_at
    inbound @first_reply

    assert_in_delta \
      Time.now-opened_at,
      @billing_enquiry.first_reply,
      1.99

    opened_at = 20.days.ago.at_beginning_of_day
    @duplicate_enquiry.update created_at:opened_at

    @first_reply.payload['msg']['to'] = [
      [ 'peldi@example.org', nil ],
      [ "request.#{@duplicate_enquiry.id}@getsupportflow.net", nil ]
    ]

    inbound @first_reply

    assert_in_delta \
      Time.now-opened_at,
      @duplicate_enquiry.first_reply,
      1.99

    average = (@billing_enquiry.first_reply + @duplicate_enquiry.first_reply) / 2

    assert_in_delta \
      average,
      Statistic::Reply.owned_by(@peldi).value.to_f,
      1.99
  end

  test "average close" do
    opened_at = 10.days.ago.at_beginning_of_day
    @billing_enquiry.update created_at:opened_at
    @billing_enquiry.update open:false
    billing_enquiry_average = Time.now-opened_at

    assert_in_delta \
      billing_enquiry_average,
      Statistic::Close.owned_by(@peldi).value.to_f,
      1.99

    opened_at = 20.days.ago.at_beginning_of_day
    @duplicate_enquiry.update created_at:opened_at
    @duplicate_enquiry.update open:false
    duplicate_enquiry_average = Time.now-opened_at

    average = (billing_enquiry_average + duplicate_enquiry_average) / 2

    assert_in_delta \
      average,
      Statistic::Close.owned_by(@peldi).value.to_f,
      1.99
  end

  test "average happiness" do
    skip
    # update 2 requests
    # ensure first reply time avearge of previous 2 requests
  end
end
