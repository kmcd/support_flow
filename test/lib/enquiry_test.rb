require 'test_helper'

class EnquiryTest < ActiveSupport::TestCase
  def email_attributes(args)
    { to:[ @support_flow_gmail.email_address ], 
      from:@peldi.email_address,
      subject:'Help', 
      body:'Help!' }.merge!(args)
  end
  
  def create_message(args={})
    Message.create content:Griddler::Email.new(email_attributes(args)),
      mailbox:@support_flow_gmail
  end
  
  test "associate with mailbox" do
    message = create_message
    assert_equal @support_flow_gmail, message.reload.mailbox
  end
  
  test "create new customer" do
    customer = 'joe@balsamiq.com'
    message = create_message from:customer
    assert_equal customer, message.reload.customer.email_address
  end
  
  test "use existing customer" do
    message = create_message
    assert_equal @peldi, message.customer
  end
  
  test "create request" do
    message = create_message
    assert_equal @peldi, message.request.customer
  end
  
  test "ignore request subject" do
    message = create_message subject:"request##{@billing_enquiry.id}"
    assert_nil message.request
  end
  
  test "ignore request to address" do
    message = create_message \
      to:["request.#{@billing_enquiry.id}@getsupportflow.com"]
    assert_nil message.request
  end
  
  test "ignore request cc address" do
    message = create_message \
      cc:["request.#{@billing_enquiry.id}@getsupportflow.com"]
    assert_nil message.request
  end
end
