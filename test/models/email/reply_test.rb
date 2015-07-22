require 'test_helper'


class ReplyTest < ActiveSupport::TestCase
  test "associate from subject" do
    # TODO: create a reply fixture
    reply = @enquiry
    reply.payload['msg']['subject'] = \
      "request.#{@billing_enquiry.id}@getsupportflow.net"

    assert_difference '@billing_enquiry.emails.count', 1 do
      reply.process_payload
      assert_equal @billing_enquiry, reply.reload.request
    end
  end

  test "associate from TO address" do
    reply = @enquiry
    reply.payload['msg']['email'] = \
      "request.#{@billing_enquiry.id}@getsupportflow.net"
    reply.payload['msg']['to'] = \
      [["request.#{@billing_enquiry.id}@getsupportflow.net", nil]]

    assert_difference '@billing_enquiry.emails.count', 1 do
      reply.process_payload
      assert_equal @billing_enquiry, reply.reload.request
    end
  end

  test "associate from CC address" do
    reply = @enquiry
    reply.payload['msg']['cc'] = \
      [["request.#{@billing_enquiry.id}@getsupportflow.net", nil]]

    assert_difference '@billing_enquiry.emails.count', 1 do
      reply.process_payload
      assert_equal @billing_enquiry, reply.reload.request
    end
  end

  test "create request when addressed to invalid id" do
    reply = @enquiry
    reply.payload['msg']['subject'] = "request.X@getsupportflow.net"

    reply.process_payload
    reply.reload
    assert reply.request.present?
    assert_equal @support_flow, reply.team
    assert_equal 1, reply.request.emails_count
  end

  test "save reply time" do
    @billing_enquiry.update created_at:5.days.ago

    reply = @enquiry
    reply.payload['msg']['to'] = \
      [["request.#{@billing_enquiry.id}@getsupportflow.net"],
        [@peldi.email_address, nil ]]
    reply.payload['msg']['from_email'] = @rachel.email_address

    reply.process_payload

    first_reply = Activity.where(trackable:@billing_enquiry,
      key:'request.first_reply').first

    five_days_in_seconds = 432000
    assert_equal five_days_in_seconds, first_reply.parameters['seconds']
    assert_equal @rachel, first_reply.owner
    assert_equal @peldi, first_reply.recipient
  end

  test "update activity stream" do
    reply = @existing_customer_enquiry
    reply.payload['msg']['to'] = \
      [["request.#{@billing_enquiry.id}@getsupportflow.net"],
        [@peldi.email_address, nil ]]
    reply.payload['msg']['from_email'] = @rachel.email_address

    reply.process_payload
    activity = Activity.where(key:'request.reply',
      trackable:@existing_customer_enquiry.request).first

    assert_equal @rachel, activity.owner
    assert_equal @peldi, activity.recipient
    assert_equal({'email_id' => @existing_customer_enquiry.id},
      activity.parameters)
  end
end
