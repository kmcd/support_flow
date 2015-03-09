require 'test_helper'

module CommandTestable
  def setup
    ActiveRecord::Base.observers.disable :enquiry_observer, :reply_observer
  end
end

class CommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "reply with help message when unknown command received" do
    # create_message content:'--foo'
    # assert command error email 
  end
end

class TagCommandTest < ActiveSupport::TestCase
  include CommandTestable
  
  test "single tag" do
    @command.content = "--tag billing"
    Command.new(@command).execute
    
    assert_equal %w[ billing ], @billing_enquiry.reload.tags
  end
  
  test "multiple tag" do
    @command.content = "--tag billing urgent"
    Command.new(@command).execute
    
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.tags
  end
  
  test "multiple tags with commas" do
    @command.content = "--tag billing, urgent"
    Command.new(@command).execute
    
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.tags
  end
  
  test "multiple tags over single line" do
    @command.content = "--tag billing --tag urgent"
    Command.new(@command).execute
    
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.tags
  end
  
  test "multiple tags over multiple lines" do
    @command.content = "--tag billing\n Foo\n --tag urgent"
    Command.new(@command).execute
    
    assert_equal %w[ billing urgent ], @billing_enquiry.reload.tags
  end
  
  test "dont add duplicate tags" do
    # TODO: move to Request
    @command.content = "--tag billing --tag billing"
    Command.new(@command).execute
    
    assert_equal %w[ billing ], @billing_enquiry.reload.tags
  end
  
  test "tags are always lower case" do
    @command.content = "--tag BILLING"
    Command.new(@command).execute
    
    assert_equal %w[ billing ], @billing_enquiry.reload.tags
  end
end

# class AgentAssignmentCommandTest < ActiveSupport::TestCase
  # test "assign specified agent" do
    # skip
  # end
  # 
  # test "DONT assign an invalid agent" do
    # skip
  # end
  
  # test "claim request for sending agent" do
    # # skip
  # end
  # 
  # test "release request for sending agent" do
    # # skip
  # end
# end
# 
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
