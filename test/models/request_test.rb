require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  test "unique labels" do
    2.times { @billing_enquiry.update label:'billing' }
    assert_equal %w[ billing ], @billing_enquiry.reload.labels
  end
  
  test "remove a label" do
    @billing_enquiry.update label:'billing'
    @billing_enquiry.update label:'-billing'
    assert_equal [], @billing_enquiry.reload.labels
  end
  
  test "save request close time" do
    @billing_enquiry.update created_at:5.days.ago
    @billing_enquiry.update open:false
    
    close_time = Activity.where(trackable:@billing_enquiry,
      key:'request.close_time').last
    
    five_days_in_seconds = 432000
    assert_equal five_days_in_seconds, close_time.parameters[:seconds]
    assert_equal @rachel, close_time.owner
    assert_equal @peldi, close_time.recipient
  end
  
  test "set number" do
    Request.delete_all
    request = Request.create team_id:1
    assert_equal 1, request.reload.number
  end
end
