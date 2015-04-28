require 'test_helper'

class CommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "close" do
    execute "--close"
    refute @billing_enquiry.reload.open?
  end
  
  test "open" do
    @billing_enquiry.update_attribute :open, false
    execute "--open"
    assert @billing_enquiry.reload.open?
  end
end

class TagCommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "single label" do
    execute "--label billing"
    assert_equal %w[ billing ], @billing_enquiry.reload.labels
  end
  
  test "multiple label" do
    execute  "--label billing urgent"
    assert_equal ['billing urgent'], @billing_enquiry.reload.labels
  end
  
  test "multiple labels over single line" do
    execute  "--label billing --label urgent"
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.labels
  end
  
  test "multiple labels over multiple lines" do
    execute "--label billing\\n Foo\\n --label urgent"
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.labels
  end
end

class AgentAssignmentCommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "assign agent by first part of email address" do
    execute "--assign keith"
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "assign agent by full email address" do
    execute "--assign keith@getsupportflow.com"
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "claim request for sending agent" do
    execute "--claim", from:@keith.email_address
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "release request for sending agent" do
    execute "--release", from:@billing_enquiry.agent.email_address
    assert_nil @billing_enquiry.reload.agent
  end
  
  test "any team agent can release a request" do
    execute "--release", from:@keith.email_address
    assert_nil @billing_enquiry.reload.agent
  end
end
  
class InvalidAgentAssignmentCommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "dont assign an invalid agent" do
    execute "--assign foo@getsupportflow.com"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "dont assign a foreign agent" do
    execute "--assign #{@peldi_support.email_address}"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "dont claim request for non-existent agent" do
    execute "--claim", from:"alice@example.org"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "dont claim request for foreign agent" do
    execute "--claim", from:@peldi.email_address
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "dont release request for foreign agent" do
    execute "--release", from:@peldi.email_address
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
end

class InvalidCommandTest < ActiveSupport::TestCase
  include CommandTestable
  
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
