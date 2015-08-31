require 'test_helper'

class CommandTest < ActionDispatch::IntegrationTest
  def email_command(args)
    command = @command
    command.payload['msg']['text'] = args
    { mandrill_events:[command.payload].to_json }
  end

  test "assign from name" do
    anonymous do
      post '/email/inbound', email_command("--assign #{@keith.name}")
      assert_response :ok
    end

    assert_equal @keith, @billing_enquiry.reload.agent

    login(@rachel) do
      assert_timeline /rachel.*assigned.*keith/mi

      get team_request_path(@support_flow.name, @billing_enquiry.number)
      assert_timeline /rachel.*assigned.*keith/mi

      get agent_path(@rachel)
      assert_timeline /rachel.*assigned.*keith/mi

      get agent_path(@keith)
      assert_timeline /rachel.*assigned.*keith/mi
    end
  end

  test "assign from email address" do
    anonymous do
      post '/email/inbound', email_command("--assign #{@keith.email_address}")
      assert_response :ok
    end

    assert_equal @keith, @billing_enquiry.reload.agent

    login(@rachel) do
      assert_timeline /rachel.*assigned.*keith/mi

      get team_request_path(@support_flow.name, @billing_enquiry.number)
      assert_timeline /rachel.*assigned.*keith/mi

      get agent_path(@rachel)
      assert_timeline /rachel.*assigned.*keith/mi

      get agent_path(@keith)
      assert_timeline /rachel.*assigned.*keith/mi
    end
  end

  test "claim" do
    @billing_enquiry.update agent:@keith

    anonymous do
      post '/email/inbound', email_command("--claim")
      assert_response :ok
    end

    assert_equal @rachel, @billing_enquiry.reload.agent

    login(@rachel) do
      assert_timeline /rachel.*assigned.*rachel/mi

      get team_request_path(@support_flow.name, @billing_enquiry.number)
      assert_timeline /rachel.*assigned.*rachel/mi

      get agent_path(@rachel)
      assert_timeline /rachel.*assigned.*rachel/mi
    end
  end

  test "close" do
    anonymous do
      post '/email/inbound', email_command("--close")
      assert_response :ok
    end

    assert @billing_enquiry.reload.closed?

    login(@rachel) do
      assert_timeline /rachel.*closed.*##{@billing_enquiry.number}/mi

      get team_request_path(@support_flow.name, @billing_enquiry.number)
      assert_timeline /rachel.*closed.*##{@billing_enquiry.number}/mi

      get agent_path(@rachel)
      assert_timeline /rachel.*closed.*##{@billing_enquiry.number}/mi
    end
  end

  test "open" do
    request_address = "request.#{@closed.id}@getsupportflow.net"
    @command.payload['msg']['email'] = request_address
    @command.payload['msg']['to'] = [ [ request_address, nil ] ]

    anonymous do
      post '/email/inbound', email_command("--open")
      assert_response :ok
    end

    assert @closed.reload.open?

    login(@rachel) do
      assert_timeline /rachel.*opened.*##{@closed.number}/mi

      get team_request_path(@support_flow.name, @closed.number)
      assert_timeline /rachel.*opened.*##{@closed.number}/mi

      get agent_path(@rachel)
      assert_timeline /rachel.*opened.*##{@closed.number}/mi
    end
  end

  test "release" do
    anonymous do
      post '/email/inbound', email_command("--release")
      assert_response :ok
    end

    assert_equal nil, @billing_enquiry.reload.agent

    login(@rachel) do
      assert_timeline /rachel.*released/mi

      get team_request_path(@support_flow.name, @billing_enquiry.number)
      assert_timeline /rachel.*released/mi

      get agent_path(@rachel)
      assert_timeline /rachel.*released/mi
    end
  end

  test "label" do
     anonymous do
      post '/email/inbound', email_command("--label urgent")
      assert_response :ok
    end

    assert_includes @billing_enquiry.reload.labels, 'urgent'

    login(@rachel) do
      assert_timeline /rachel.*label.*urgent/mi

      get team_request_path(@support_flow.name, @billing_enquiry.number)
      assert_timeline /rachel.*label.*urgent/mi

      get agent_path(@rachel)
      assert_timeline /rachel.*label.*urgent/mi
    end
  end
end
