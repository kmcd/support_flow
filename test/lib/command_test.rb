require 'test_helper'

module CommandTestable
  def setup
    ActiveRecord::Base.observers.disable :enquiry_observer, :reply_observer
  end
  
  def execute(command)
    @command.content = command
    Command.new(@command).execute
  end
end

class CommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "reply with help message when unknown command received" do
    @command.content = "--foo bar"
    command = Command.new @command
    command.execute
    
    assert_equal "invalid option: --foo", command.errors.first.message
  end
end

class CommandTagTest < ActiveSupport::TestCase
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

class CommandAgentAssignmentTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "assign agent by first part of email address" do
    assert_equal @rachel, @billing_enquiry.agent
    execute "--assign keith"
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "assign agent by full email address" do
    execute "--assign keith@getsupportflow.com"
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "DONT assign an invalid agent" do
    execute "--assign foo@getsupportflow.com"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "DONT assign a foreign agent" do
    execute "--assign #{@peldi_support.email_address}"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "claim request for sending agent" do
    @command.agent = @keith
    execute "--claim"
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "DONT claim request for non-existant agent" do
    @command.agent = nil
    execute "--claim"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "DONT claim request for foreign agent" do
    @command.agent = @peldi_support
    execute "--claim"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
  
  test "release request for sending agent" do
    @command.agent = @keith
    execute "--release"
    assert_nil @billing_enquiry.reload.agent
  end
  
  test "DONT release request for foreign agent" do
    @command.agent = @peldi_support
    execute "--release"
    assert_equal @rachel, @billing_enquiry.reload.agent
  end
end

class CommandStatusUpdateTest < ActiveSupport::TestCase
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

class CommandTemplateReplyTest < ActiveSupport::TestCase
  test "reply with default template" do
    skip
  end
  
  test "reply with specified template" do
    skip
  end
end
