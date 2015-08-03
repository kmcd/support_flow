require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  def setup
    super
    @billing_enquiry.current_agent = @rachel
  end

  test "set number" do
    Request.delete_all
    request = Request.create team_id:1
    assert_equal 1, request.reload.number
  end

  test "assignment activity" do
    @billing_enquiry.update agent:@keith
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.assign').last

    assert_equal @rachel, activity.owner
    assert_equal @keith, activity.recipient
  end

  test "rename activity" do
    original_name = @billing_enquiry.name
    @billing_enquiry.update name:'Card expiry'
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.rename').last

    assert_equal original_name, activity.parameters['from']
    assert_equal @billing_enquiry.name, activity.parameters['to']
  end

  test "add label activity" do
    @billing_enquiry.update labels:%w[ urgent ]
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.label').last

    assert_equal @billing_enquiry.labels, activity.parameters['label']
  end

  test "remove label activity" do
    @billing_enquiry.update labels:%w[ urgent ]
    @billing_enquiry.update labels:%w[ billing ]
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.label.remove').last

    assert_equal %w[ urgent ], activity.parameters['label']
  end

  test "close activity" do
    @billing_enquiry.update open:false
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.close').last
    assert activity
  end

  test "change customer activity" do
    @billing_enquiry.update customer:@tobi
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.customer').last

    assert_equal @tobi, activity.recipient
    assert_equal(@peldi, Customer.
      find(activity.parameters['previous_customer_id']))
  end

  test "update customer happiness activity" do
    original_happiness = @billing_enquiry.happiness
    @billing_enquiry.update happiness:75
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.happiness').last

    assert_equal @peldi, activity.recipient
    assert_equal original_happiness, activity.parameters['was']
    assert_equal @billing_enquiry.happiness, activity.parameters['now']
  end

  test "add notes activity" do
    @billing_enquiry.update notes:'foo'
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.notes').last
    assert activity
  end

  test "close time" do
    @billing_enquiry.update created_at:5.days.ago
    @billing_enquiry.update open:false

    close_time = Activity.where(trackable:@billing_enquiry,
      key:'request.close').last

    five_days_in_seconds = 432000
    assert_equal five_days_in_seconds, close_time.parameters['close_time_in_seconds']
    assert_equal @rachel, close_time.owner
    assert_equal @peldi, close_time.recipient
  end
  
  test "re-open activity" do
    @billing_enquiry.update open:false
    @billing_enquiry.update open:true
    activity = Activity.where(trackable:@billing_enquiry,
      key:'request.reopen').last
    assert activity
  end
end
