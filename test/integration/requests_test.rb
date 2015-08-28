require 'test_helper'

class RequestsTest < ActionDispatch::IntegrationTest
  test "inbound email enquiry" do
    anonymous do
      post '/email/inbound', mandrill_events:[@enquiry.payload].to_json
      assert_response :ok
    end

    login(@rachel) do
      enquiry = @support_flow.requests.
        where(name:@enquiry.payload['msg']['subject']).first

      assert_timeline do
        assert_select 'a', href:customer_path(enquiry.customer)
        assert_select 'a', href:team_requests_path(@support_flow,
          enquiry.number)
        assert_select '*', /opened/i
      end
    end
  end

  test "inbound email reply" do
    anonymous do
      post '/email/inbound',
        mandrill_events:[@existing_customer_reply.payload].to_json

      assert_response :ok
    end

    login(@rachel) do
      assert_timeline do
        assert_select 'a', href:customer_path(@peldi)
        assert_select 'a', href:team_requests_path(@support_flow,
          @billing_enquiry.number)
        assert_select '*', /opened/i
      end
    end
  end

  test "outbound reply" do
    login(@rachel) do
      get team_request_url(@support_flow.name, @billing_enquiry.number)

      assert_response :success
      assert_select('form', method:'post', action:email_outbound_index_path) do
        assert_select 'input', name:'email_outbound[request_id]',
          value:@billing_enquiry.id
        assert_select 'input', type:'text', name:'email_outbound[recipients]'
        assert_select 'textarea', name:'email_outbound[message_content]'
        assert_select 'input', type:'file',
          name:'email_outbound[attachments][]', multiple:'multiple'
      end

      post \
        email_outbound_index_path(format:'js'),
        email_outbound:{
          request_id:@billing_enquiry.id,
          recipients:"to@example.net cc:cc@example.net, BCC:bcc@example.net asd",
          message_content:'<p>Hello</p>' }

      assert_response :success

      email = ActionMailer::Base.deliveries.last

      assert_equal [ @rachel.email_address ], email.from
      assert_equal %w[ to@example.net ], email.to
      assert_equal %w[ cc@example.net ], email.cc
      assert_equal %W[ bcc@example.net request.#{@billing_enquiry.id}@getsupportflow.net ],
        email.bcc
      assert_equal @billing_enquiry.name, email.subject

      mail_text = email.parts.find {|_| _.content_type =~ /text\/plain/i }
      mail_html = email.parts.find {|_| _.content_type =~ /html/i }

      assert_equal 'Hello', mail_text.body.to_s
      assert_equal '<p>Hello</p>', mail_html.body.to_s
    end
  end

  test "demo outbound reply" do
    @support_flow.update subscription:'demo'

    login(@rachel) do
      post \
        email_outbound_index_path(format:'js'),
        email_outbound:{
          request_id:@billing_enquiry.id,
          recipients:"to@example.net cc:cc@example.net, BCC:bcc@example.net asd",
          message_content:'<p>Hello</p>' }

      assert_response :success

      email = ActionMailer::Base.deliveries.last

      assert_equal %W[ request.#{@billing_enquiry.id}@getsupportflow.net ], email.from
      assert_equal [ @rachel.email_address ], email.to
    end
  end

  test "first reply" do
    skip
    # reply to request
    # ensure first reply time calculation correct
  end

  test "canned response" do
    skip
  end

  test "editing" do
    skip
  end

  test "outbound attachments" do
    skip
  end
end
