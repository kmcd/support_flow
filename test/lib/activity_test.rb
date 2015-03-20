require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  test "request open" do
    enquiry = Enquiry.new email(from:@peldi.email_address)
    enquiry.stubs(:valid?).returns true
    enquiry.save
    activity = enquiry.request.activities.first
    
    assert_equal @peldi, activity.owner
    assert_equal 'request.open', activity.key
    assert_equal({message_id:enquiry.message.id}, activity.parameters)
  end
    
  test "request reply" do
    reply = Reply.new email(
      subject:"request##{@billing_enquiry.id}",
      from:@rachel.email_address )
    reply.save
    activity = reply.request.activities.first
    message = reply.request.messages.last
    
    assert_equal @rachel, activity.owner
    assert_equal 'request.reply', activity.key
    assert_equal({message_id:message.id}, activity.parameters)
  end
end

class CommandActivityTest < ActiveSupport::TestCase
  include CommandTestable
  
  def command_activity(command)
    execute command
    @billing_enquiry.activities.first
  end
  
  test "set agent from email sender" do
    activity = command_activity "--tag billing"
    assert_equal @rachel, activity.owner
  end
  
  test "tag" do
    activity = command_activity "--tag billing"
    
    assert_equal 'request.tag', activity.key
    assert_equal({tags:'billing'}, activity.parameters)
  end
  
  test "assign" do
    activity = command_activity "--assign keith"
    
    assert_equal 'request.assign', activity.key
    assert_equal({agent_id:@keith.id}, activity.parameters)
  end
  
  test "claim" do
    activity = command_activity "--claim"
    
    assert_equal 'request.assign', activity.key
    assert_equal({agent_id:@rachel.id}, activity.parameters)
  end
  
  test "release" do
    activity = command_activity "--release"
    
    assert_equal 'request.assign', activity.key
    assert_equal({agent_id:nil}, activity.parameters)
  end
  
  test "close" do
    activity = command_activity "--close"
    assert_equal 'request.close', activity.key
  end
  
  test "open" do
    activity = command_activity "--open"
    assert_equal 'request.open', activity.key
  end
end
