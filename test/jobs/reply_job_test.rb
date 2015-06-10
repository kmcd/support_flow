require 'test_helper'

class ReplyJobTest < ActiveJob::TestCase
  # TODO: dry up fixture setting

  test "associate from subject" do
    reply = @enquiry
    reply.payload['msg']['subject'] = \
      "request.#{@billing_enquiry.id}@getsupportflow.net"

    assert_difference '@billing_enquiry.emails.count', 1 do
      ReplyJob.perform_now(reply)
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
      ReplyJob.perform_now(reply)
      assert_equal @billing_enquiry, reply.reload.request
    end
  end

  test "associate from CC address" do
    reply = @enquiry
    reply.payload['msg']['cc'] = \
      [["request.#{@billing_enquiry.id}@getsupportflow.net", nil]]

    assert_difference '@billing_enquiry.emails.count', 1 do
      ReplyJob.perform_now(reply)
      assert_equal @billing_enquiry, reply.reload.request
    end
  end

  test "ignore invalid request id" do
    reply = @enquiry
    reply.payload['msg']['subject'] = "request.X@getsupportflow.net"

    assert_difference 'Email.count', 0 do
      ReplyJob.perform_now(reply)
      assert_nil reply.reload.request
    end
  end

  test "save reply time" do
    open = Activity.create trackable:@billing_enquiry,
      key:'request.open', created_at:5.days.ago

    reply = @enquiry
    reply.payload['msg']['to'] = \
      [["request.#{@billing_enquiry.id}@getsupportflow.net"],
        [@peldi.email_address, nil ]]
    reply.payload['msg']['from_email'] = @rachel.email_address

    ReplyJob.perform_now(reply)

    first_reply = Activity.where(trackable:@billing_enquiry,
      key:'request.first_reply').first

    five_days_in_seconds = 432000
    assert_equal five_days_in_seconds, first_reply.parameters[:seconds]
    assert_equal @rachel, first_reply.owner
    assert_equal @peldi, first_reply.recipient
  end

  test "update activity stream" do
    reply = @existing_customer_enquiry
    reply.payload['msg']['to'] = \
      [["request.#{@billing_enquiry.id}@getsupportflow.net"],
        [@peldi.email_address, nil ]]
    reply.payload['msg']['from_email'] = @rachel.email_address 
      
    ReplyJob.perform_now(reply)
    activity = reply.reload.request.activities.
      where(key:'request.reply').first

    assert_equal @rachel, activity.owner
    assert_equal @peldi, activity.recipient
    assert_equal({email_id:@existing_customer_enquiry.id},
      activity.parameters)
  end
end
