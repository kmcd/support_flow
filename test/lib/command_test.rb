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
  test "assign specified agent" do
    skip
  end
  
  test "DONT assign an invalid agent" do
    skip
  end
  
  test "claim request for sending agent" do
    # skip
  end
  
  test "release request for sending agent" do
    # skip
  end
end


# class TemplateReplyCommandTest < ActiveSupport::TestCase
  # test "reply with default template" do
    # skip
  # end
  # 
  # test "reply with specified template" do
    # skip
  # end
# end

# test "report" do
  # # create_message content:'--report'
  # # assert command error email 
# end
# 
