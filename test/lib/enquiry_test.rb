require 'test_helper'

class EnquiryTest < ActiveSupport::TestCase
  attr_reader :enquiry
  
  def email(options={})
    Griddler::Email.new( \
      to:[@support_flow_gmail.email_address],
      from:'customer@example.org' )
  end
  
  def setup
    @enquiry = Enquiry.new email
    enquiry.stubs(:valid?).returns true
    enquiry.save
  end
  
  test "create message" do
    assert enquiry.message.persisted?
  end
  
  test "assign to correct mailbox" do
    assert_equal @support_flow_gmail, enquiry.mailbox
  end
  
  test "create new request" do
    assert enquiry.request.persisted?
  end
  
  test "create new customer" do
    assert_equal email.from[:email], \
      enquiry.customer.email_address
  end
end

class ExistingCustomerEnquiryTest < ActiveSupport::TestCase
  attr_reader :enquiry
  
  def setup
    @enquiry = Enquiry.new Griddler::Email.new \
      to:[@support_flow_gmail.email_address],
      from:@peldi.email_address
    enquiry.stubs(:valid?).returns true
    Message.create! mailbox:@support_flow_gmail, customer:@peldi, content:''
  end
  
  test "use existing customer" do
    assert_difference 'Customer.count', 0 do
      enquiry.save
      assert_equal @peldi.email_address, enquiry.customer.email_address
    end
  end
end

class InvalidEnquiryTest < ActiveSupport::TestCase
  def email(options={})
    Griddler::Email.new( \
      { to:[@support_flow_gmail.email_address],
      from:'customer@example.org' }.merge!(options) )
  end
  
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
