require 'test_helper'

class CommandTest < ActionDispatch::IntegrationTest
  def email_command(args)
    command = @command
    command.payload['msg']['text'] = args
    { mandrill_events:[command.payload].to_json }
  end

  test "assign agent from name" do
    anonymous do
      post '/email/inbound', email_command("--assign #{@keith.name}")
      assert_response :ok
    end

    login(@rachel) do
      # Dashboard timeline
      assert_select '.timeline-item' do
        assert_select '*', /assigned/i
      end

      # Agent timeline
      assert_select 'request' do
      end

      # Request
      assert_select 'request' do
      end

      # Request timeline
      assert_select 'request' do
      end
    end
  end

  test "assign agent from email address" do
    flunk
    @billing_enquiry.assign_from @keith.email_address
    assert_equal @keith, @billing_enquiry.reload.agent
  end

  test "claim command" do
    flunk
    @billing_enquiry.update agent:@keith
    assign_command = @command
    assign_command.payload['msg']['text'] = "--claim"
    assign_command.process_payload

    assert_equal @rachel, @billing_enquiry.reload.agent
  end

  test "close command" do
    flunk
    assign_command = @command
    assign_command.payload['msg']['text'] = "--close"
    assign_command.process_payload

    assert @billing_enquiry.reload.closed?
  end

  test "open command" do
    flunk
    @billing_enquiry.update open:false
    assign_command = @command
    assign_command.payload['msg']['text'] = "--open"
    assign_command.process_payload

    assert @billing_enquiry.reload.open?
  end

  test "release command" do
    flunk
    assign_command = @command
    assign_command.payload['msg']['text'] = "--release"
    assign_command.process_payload

    assert_nil @billing_enquiry.reload.agent
  end

  test "label command" do
    flunk
    assign_command = @command
    assign_command.payload['msg']['text'] = "--label urgent"
    assign_command.process_payload

    assert_equal ['urgent'], @billing_enquiry.reload.labels
  end
end
