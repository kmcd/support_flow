require 'test_helper'

class Email::InboundTest < ActiveSupport::TestCase
  test "set agent" do
    @agent_enquiry.process_payload
    assert_equal @rachel, @agent_enquiry.reload.agent
  end

  test "set team" do
    @agent_enquiry.process_payload
    @agent_enquiry.reload

    assert_equal @support_flow, @agent_enquiry.team
    assert_equal @support_flow, @agent_enquiry.request.team
  end

  test "set recipients" do
    @agent_enquiry.process_payload

    assert_equal "team.181813285@getsupportflow.net", @agent_enquiry.recipients
  end

  test "associate request" do
    @command.process_payload

    assert_equal @billing_enquiry, @command.reload.request
  end

  test "associate existing customer when request customer blank" do
    @billing_enquiry.update customer:nil
    @existing_customer_reply.process_payload
    assert_equal @peldi, @billing_enquiry.reload.customer
  end

  test "associate existing customer when request customer present" do
    @billing_enquiry.update customer:@tobi
    @existing_customer_reply.process_payload

    assert_equal @tobi, @billing_enquiry.reload.customer
    assert_equal @peldi, @existing_customer_reply.sender
  end

  test "new customer enquiry" do
    @enquiry.process_payload

    assert_equal "new_customer@example.com", @enquiry.request.customer.
      email_address
  end

  test "new customer reply" do
    @new_customer_reply.process_payload

    assert_equal "new_customer@example.com", @new_customer_reply.sender.
      email_address
    assert_equal @peldi, @billing_enquiry.customer
  end

  test "new customer enquiry activity" do
    @enquiry.process_payload
    activity = Activity.where(key:'request.open').last

    assert_equal @support_flow, activity.team
    assert_equal @enquiry.message.from, activity.owner.email_address
    assert_equal @enquiry.id, activity.parameters['email_id']
  end

  test "existing customer enquiry activity" do
    @existing_customer_enquiry.process_payload
    activity = Activity.where(key:'request.open').last

    assert_equal @peldi, activity.owner
  end

  test "first reply activity" do
    @billing_enquiry.update created_at:1.minute.ago
    @first_reply.process_payload
    activity = Activity.where(key:'request.first_reply').last

    assert_equal @support_flow, activity.team
    assert_equal @billing_enquiry, activity.trackable
    assert_equal @rachel, activity.owner
    assert_equal @peldi, activity.recipient
    assert_equal 60, activity.parameters['seconds']

    assert_no_difference("Activity.where(key:'request.first_reply').count") do
      @first_reply.process_payload
    end
  end

  test "agent reply activity" do
    @first_reply.process_payload
    activity = Activity.where(key:'request.reply').last

    assert_equal @support_flow, activity.team
    assert_equal @billing_enquiry, activity.trackable
    assert_equal @rachel, activity.owner
    assert_equal @peldi, activity.recipient
    assert_equal @first_reply.id, activity.parameters['email_id']
  end

  test "assign command" do
    assign_command = @command
    assign_command.payload['msg']['text'] = "--assign #{@keith.name}"
    assign_command.process_payload

    assert_equal @keith, @billing_enquiry.reload.agent
  end

  test "claim command" do
    @billing_enquiry.update agent:@keith
    assign_command = @command
    assign_command.payload['msg']['text'] = "--claim"
    assign_command.process_payload

    assert_equal @rachel, @billing_enquiry.reload.agent
  end

  test "close command" do
    assign_command = @command
    assign_command.payload['msg']['text'] = "--close"
    assign_command.process_payload

    assert @billing_enquiry.reload.closed?
  end

  test "open command" do
    @billing_enquiry.update open:false
    assign_command = @command
    assign_command.payload['msg']['text'] = "--open"
    assign_command.process_payload

    assert @billing_enquiry.reload.open?
  end

  test "release command" do
    assign_command = @command
    assign_command.payload['msg']['text'] = "--release"
    assign_command.process_payload

    assert_nil @billing_enquiry.reload.agent
  end

  test "label command" do
    assign_command = @command
    assign_command.payload['msg']['text'] = "--label urgent"
    assign_command.process_payload

    assert_equal ['urgent'], @billing_enquiry.reload.labels
  end
end
