require 'test_helper'

class ReplyTest < ActiveSupport::TestCase
  test "associate from subject" do
    reply = Reply.new email subject:"request##{@billing_enquiry.id}"
    
    assert_difference 'reply.request.messages.count', 1 do
      reply.save
      assert_equal @billing_enquiry, reply.request
    end
  end
  
  test "associate from TO address" do
    reply = Reply.new \
      email to:["request.#{@billing_enquiry.id}@getsupportflow.net"]
    
    assert_difference 'reply.request.messages.count', 1 do
      reply.save
      assert_equal @billing_enquiry, reply.request
    end
  end
  
  test "associate from CC address" do
    reply = Reply.new \
      email cc:["request.#{@billing_enquiry.id}@getsupportflow.net"]
    
    assert_difference 'reply.request.messages.count', 1 do
      reply.save
      assert_equal @billing_enquiry, reply.request
    end
  end
  
  test "assign to mailbox" do
    reply = Reply.new \
      email cc:["request.#{@billing_enquiry.id}@getsupportflow.net"]
    reply.save
    
    assert_equal @support_flow_gmail, reply.message.mailbox
  end
  
  test "assign customer" do
    reply = Reply.new email \
      to:["request.#{@billing_enquiry.id}@getsupportflow.net"],
      from:@peldi.email_address
    reply.save
      
    assert_equal @peldi, reply.message.customer
    assert_nil reply.message.agent
  end
  
  test "assign agent" do
    reply = Reply.new email \
      to:["request.#{@billing_enquiry.id}@getsupportflow.net"],
      from:@rachel.email_address
    reply.save
    
    assert_equal @rachel, reply.message.agent
    assert_nil reply.message.customer
  end
end

class NewCustomerReplyTest < ActiveSupport::TestCase
  test "create new customer" do
    reply = Reply.new email \
      to:["request.#{@billing_enquiry.id}@getsupportflow.net"],
      from:'foo@bar.com'
    reply.save
    
    assert_not_nil reply.request.team.customers.
      where(email_address:'foo@bar.com').first
  end
end

class InvalidReplyTest < ActiveSupport::TestCase
  test "ignore invalid request id" do
    refute Reply.new(email(to:["request.XXX@getsupportflow.net"])).save
    refute Reply.new(email(to:["request.123@getsupportflow.net"])).save
  end
end
