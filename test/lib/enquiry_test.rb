require 'test_helper'

class EnquiryTest < ActiveSupport::TestCase
  attr_reader :enquiry
  
  def setup
    @enquiry = Enquiry.new email
    enquiry.stubs(:valid?).returns true
    enquiry.save
  end
  
  test "create message" do
    assert enquiry.message.persisted?
  end
  
  test "assign to correct mailbox" do
    assert_equal @support_flow_gmail, enquiry.message.mailbox
  end
  
  test "create new request" do
    assert enquiry.request.persisted?
  end
  
  test "create new customer" do
    assert_equal email.from[:email], \
      enquiry.customer.email_address
  end
  
  test "increment request message counter" do
    assert_equal 1, enquiry.request.messages_count
  end
end

class AgentEnquiryTest < ActiveSupport::TestCase
  test "dont create new customer for agent request" do
    enquiry = Enquiry.new email(from:@rachel.email_address)
    enquiry.stubs(:valid?).returns true
    enquiry.save
    assert_nil enquiry.customer
  end
end

class ExistingCustomerEnquiryTest < ActiveSupport::TestCase
  attr_reader :enquiry
  
  def setup
    @enquiry = Enquiry.new email(from:@peldi.email_address)
    Message.create! mailbox:@support_flow_gmail, customer:@peldi, content:''
    enquiry.stubs(:valid?).returns true
  end
  
  test "use existing customer" do
    assert_difference 'Customer.count', 0 do
      enquiry.save
      assert_equal @peldi.email_address, enquiry.customer.email_address
    end
  end
end

class InvalidEnquiryTest < ActiveSupport::TestCase
  def invalid_reply_command
    Command.any_instance.stubs(:valid?).returns false
    Reply.any_instance.stubs(:valid?).returns false
  end
  
  test "process a valid enquiry" do
    invalid_reply_command
    enquiry = Enquiry.new email
    enquiry.save
    assert enquiry.message.persisted?
  end
  
  test "ingore non-existent mailboxes" do
    invalid_reply_command
    enquiry = Enquiry.new email(to:['foo@example.org'])
    enquiry.save
    refute enquiry.message.persisted?
  end
  
  test "dont process request reply" do
    Reply.any_instance.stubs(:valid?).returns true
    enquiry = Enquiry.  new email
    enquiry.save
    refute enquiry.message.persisted?
  end
  
  test "dont process command" do
    Command.any_instance.stubs(:valid?).returns true
    enquiry = Enquiry.new email
    enquiry.save
    refute enquiry.message.persisted?
  end
end
