require 'test_helper'

class ReplyTest < ActiveSupport::TestCase
  test "ignore first enquiry" do
    skip
    message = create_message subject:"Help!"
    assert_not_equal @billing_enquiry, message.request
  end
  
  test "associate from subject" do
    skip
    message = create_message subject:"request##{@billing_enquiry.id}"
    assert_equal @billing_enquiry, message.request
  end
  
  test "associate from TO address" do
    skip
    message = create_message \
      to:["request.#{@billing_enquiry.id}@getsupportflow.com"]
    assert_nil message.request
  end
  
  test "associate from CC address" do
    skip
    message = create_message \
      cc:["request.#{@billing_enquiry.id}@getsupportflow.com"]
    assert_nil message.request
  end
  
  test "ignore foreign agents" do
    skip
    message = create_message subject:"request#1", from:"foo@example.org"
    assert_equal @billing_enquiry, message.request
  end
end
