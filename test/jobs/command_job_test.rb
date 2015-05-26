require 'test_helper'

class CommandJobTest < ActiveJob::TestCase
  def execute(syntax, from_email='')
    fixture = @command
    fixture.payload['msg']['subject'] = \
      "request.#{@billing_enquiry.id}@getsupportflow.net"
    fixture.payload['msg']['from_email'] = from_email if from_email.present?
    fixture.payload['msg']['text'] = syntax
    CommandJob.perform_now fixture
  end
  
  test "close" do
    execute "--close"
    refute @billing_enquiry.reload.open?
  end
  
  test "open" do
    @billing_enquiry.update open:false
    execute "--open"
    assert @billing_enquiry.reload.open?
  end
  
  test "single label" do
    execute "--label billing"
    assert_equal %w[ billing ], @billing_enquiry.reload.labels
  end
  
  test "multiple labels" do
    execute "--label billing urgent"
    assert_equal ['billing urgent'], @billing_enquiry.reload.labels
  end
  
  test "multiple labels over single line" do
    execute "--label billing --label urgent"
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.labels
  end
  
  test "multiple labels over multiple lines" do
    execute "--label billing\\n Foo\\n --label urgent"
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.labels
  end
  
  test "assign agent by first part of email address" do
    execute "--assign keith"
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "assign agent by full email address" do
    execute "--assign keith@getsupportflow.com"
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "claim request for sending agent" do
    execute "--claim", @keith.email_address
    # assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "release request for sending agent" do
    execute "--release", @billing_enquiry.agent.email_address
    assert_nil @billing_enquiry.reload.agent
  end
  
  test "any team agent can release a request" do
    execute "--release", @keith.email_address
    assert_nil @billing_enquiry.reload.agent
  end
  
  test "dont assign an invalid agent" do
    execute "--assign foo@getsupportflow.com"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "dont assign a foreign agent" do
    execute "--assign #{@peldi_support.email_address}"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "dont claim request for non-existent agent" do
    execute "--claim", "alice@example.org"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "dont claim request for foreign agent" do
    execute "--claim", @peldi.email_address
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "dont release request for foreign agent" do
    execute "--release", @peldi.email_address
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "reply with help message when unknown command received" do
    command = execute "--foo"
    assert_equal "invalid option: --foo", command.errors.first.to_s
  end
  
  test "ingore previous commands in reply section" do
    [ "\n-- Reply ABOVE THIS LINE --\n--label bug",
      "\n-- On 2010-01-01 12:00:00 Tristan wrote: --\n--label bug"
    ].each do |reply_format|
      command = execute reply_format
      refute_includes @billing_enquiry.labels, 'bug'
    end
  end
end

class CommandActivityTest < ActiveSupport::TestCase
  def command_activity(syntax)
    fixture = @command
    fixture.payload['msg']['subject'] = \
      "request.#{@billing_enquiry.id}@getsupportflow.net"
    fixture.payload['msg']['from_email'] = @rachel.email_address
    fixture.payload['msg']['text'] = syntax
    CommandJob.perform_now fixture
    
    @billing_enquiry.activities.last
  end
  
  test "set agent from email sender" do
    activity = command_activity "--label billing"
    assert_equal @rachel, activity.owner
  end
  
  test "label" do
    activity = command_activity "--label billing"
    
    assert_equal 'request.label', activity.key
    assert_equal({labels:'billing'}, activity.parameters)
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
