require 'test_helper'

class AgentsTest < ActionDispatch::IntegrationTest
  def setup
    @keith.update notification_policy:{ open:false, assign:false, close:false }
    ActionMailer::Base.deliveries.clear
  end
  
  test "open notification" do
    # TODO: investigate where other 3 requests are created
    Request.delete_all
    request = @support_flow.requests.create customer:@peldi

    request_address = "request.#{request.id}@getsupportflow.net"
    email = ActionMailer::Base.deliveries.last

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal [ @rachel.email_address ], email.to
    assert_equal [request_address], email.from
    assert_match /request.*open/i, email.subject
    assert_match /request.*open/im, email.body.to_s
    assert_match /https:\/\/test.getsupportflow.net\/#{@support_flow.name}\/requests\/#{request.number}/im, email.body.to_s
  end

  test "assign notification" do
    @billing_enquiry.update agent:nil
    @billing_enquiry.update current_agent:@keith, agent:@rachel
    request_address = "request.#{@billing_enquiry.id}@getsupportflow.net"
    email = ActionMailer::Base.deliveries.last

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal [ @rachel.email_address ], email.to
    assert_equal [request_address], email.from
    assert_match /request.*assign/i, email.subject
    assert_match /request.*assign/im, email.body.to_s
    assert_match /https:\/\/test.getsupportflow.net\/#{@support_flow.name}\/requests\/#{@billing_enquiry.number}/im, email.body.to_s
  end

  test "close notification" do
    @billing_enquiry.update current_agent:@keith, open:false
    request_address = "request.#{@billing_enquiry.id}@getsupportflow.net"
    email = ActionMailer::Base.deliveries.last

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal [ @rachel.email_address ], email.to
    assert_equal [request_address], email.from
    assert_match /request.*close/i, email.subject
    assert_match /request.*close/im, email.body.to_s
    assert_match /https:\/\/test.getsupportflow.net\/#{@support_flow.name}\/requests\/#{@billing_enquiry.number}/im, email.body.to_s
  end

  test "average first reply" do
    skip
    # reply to
    # ensure first reply time calculation correct
  end

  test "average close" do
    skip
    # reply to
    # ensure first reply time calculation correct
  end

  test "average customer happiness" do
    skip
    # reply to
    # ensure first reply time calculation correct
  end
end
