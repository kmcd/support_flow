require 'test_helper'

class CommandTest < ActionDispatch::IntegrationTest
  test "assign agent from name" do
    skip
    @billing_enquiry.assign_from @keith.name.downcase
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "assign agent from email address" do
    skip
    @billing_enquiry.assign_from @keith.email_address
    assert_equal @keith, @billing_enquiry.reload.agent
  end
  
  test "assign command" do
    skip
    assign_command = @command
    assign_command.payload['msg']['text'] = "--assign #{@keith.name}"
    assign_command.process_payload

    assert_equal @keith, @billing_enquiry.reload.agent
  end

  test "claim command" do
    skip
    @billing_enquiry.update agent:@keith
    assign_command = @command
    assign_command.payload['msg']['text'] = "--claim"
    assign_command.process_payload

    assert_equal @rachel, @billing_enquiry.reload.agent
  end

  test "close command" do
    skip
    assign_command = @command
    assign_command.payload['msg']['text'] = "--close"
    assign_command.process_payload

    assert @billing_enquiry.reload.closed?
  end

  test "open command" do
    skip
    @billing_enquiry.update open:false
    assign_command = @command
    assign_command.payload['msg']['text'] = "--open"
    assign_command.process_payload

    assert @billing_enquiry.reload.open?
  end

  test "release command" do
    skip
    assign_command = @command
    assign_command.payload['msg']['text'] = "--release"
    assign_command.process_payload

    assert_nil @billing_enquiry.reload.agent
  end

  test "label command" do
    skip
    assign_command = @command
    assign_command.payload['msg']['text'] = "--label urgent"
    assign_command.process_payload

    assert_equal ['urgent'], @billing_enquiry.reload.labels
  end
end
