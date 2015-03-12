require 'test_helper'

module CommandTestable
  def execute(command, options={})
    args = {
      text:command,
      to:%W[ request.#{@billing_enquiry.id}@getsupportflow.net ], 
      from:@billing_enquiry.agent.email_address
    }.merge! options
    
    command = Command.new Griddler::Email.new args
    command.execute
    command
  end
end

class TagCommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "single tag" do
    execute "--tag billing"
    assert_equal %w[ billing ], @billing_enquiry.reload.tags
  end
  
  test "multiple tag" do
    execute  "--tag billing urgent"
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.tags
  end
  
  test "multiple tags with commas" do
    execute "--tag billing, urgent"
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.tags
  end
  
  test "multiple tags over single line" do
    execute  "--tag billing --tag urgent"
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.tags
  end
  
  test "multiple tags over multiple lines" do
    execute "--tag billing\n Foo\n --tag urgent"
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.tags
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

class StatusUpdateCommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "open request" do
    execute "--status open"
    assert_equal 'open', @billing_enquiry.reload.status
  end
  
  test "close request" do
    execute "--status close"
    assert_equal 'close', @billing_enquiry.reload.status
  end
end

class InvalidCommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "reply with help message when unknown command received" do
    command = execute "--foo"
    assert_equal "invalid option: --foo", command.errors.first.to_s
  end
  
  test "ingore previous commands in reply section" do
    [ "\n-- Reply ABOVE THIS LINE --\n--tag bug",
      "\n-- On 2010-01-01 12:00:00 Tristan wrote: --\n--tag bug"
    ].each do |reply_format|
      command = execute reply_format
      assert_empty @billing_enquiry.tags, reply_format
    end
  end
end
