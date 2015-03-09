require 'test_helper'

class CommandTest < ActiveSupport::TestCase
  def setup
    ActiveRecord::Base.observers.disable :enquiry_observer, :reply_observer
  end
  
  test "tag request" do
    @command.content = "--tag billing"
    Command.new(@command).execute
    
    assert_equal %w[ billing ], @billing_enquiry.reload.tags
  end
  
  # test "claim request for sending agent" do
    # # skip
  # end
  # 
  # test "release request for sending agent" do
    # # skip
  # end
  # 
  # test "report" do
    # # create_message content:'--report'
    # # assert command error email 
  # end
  # 
  # test "reply with help message when unknown command received" do
    # # create_message content:'--foo'
    # # assert command error email 
  # end
end

# class AssignAgentCommandTest < ActiveSupport::TestCase
  # test "assign specified agent" do
    # skip
  # end
  # 
  # test "DONT assign an invalid agent" do
    # skip
  # end
# end
# 
# class ReplyCommandTest < ActiveSupport::TestCase
  # test "reply with default template" do
    # skip
  # end
  # 
  # test "reply with specified template" do
    # skip
  # end
# end
