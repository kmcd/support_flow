require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  include CommandTestable
  
  def command_activity(command)
    execute command
    @billing_enquiry.activities.first
  end
  
  test "set agent from email sender" do
    activity = command_activity "--tag billing"
    
    assert_equal @rachel, activity.owner
  end
  
  test "tag command" do
    activity = command_activity "--tag billing"
    
    assert_equal 'request.tag', activity.key
    assert_equal({tags:'billing'}, activity.parameters)
  end
  
  test "assign command" do
    activity = command_activity "--assign keith"
    
    assert_equal 'request.assign', activity.key
    assert_equal({agent_id:@keith.id}, activity.parameters)
  end
  
  test "claim command" do
    activity = command_activity "--claim"
    
    assert_equal 'request.assign', activity.key
    assert_equal({agent_id:@rachel.id}, activity.parameters)
  end
  
  test "release command" do
    activity = command_activity "--release"
    
    assert_equal 'request.assign', activity.key
    assert_equal({agent_id:nil}, activity.parameters)
  end
  
  
  # enquiry
  # reply
end
