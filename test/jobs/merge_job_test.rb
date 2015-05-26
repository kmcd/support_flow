require 'test_helper'

class MergeJobTest < ActiveJob::TestCase
  test "merge emails" do
    @enquiry.update request:@duplicate_enquiry
    MergeJob.perform_now @billing_enquiry, @duplicate_enquiry
    
    assert_includes @billing_enquiry.reload.emails, @enquiry
  end
  
  test "delete duplicate emails" do
    @enquiry.update request:@duplicate_enquiry
    MergeJob.perform_now @billing_enquiry, @duplicate_enquiry
    
    assert_empty Email.where(request:@duplicate_enquiry).all
  end
  
  test "delete duplicate request" do
    MergeJob.perform_now @billing_enquiry, @duplicate_enquiry
    assert_raises(ActiveRecord::RecordNotFound) { @duplicate_enquiry.reload }
  end
  
  test "merge activities" do
    activity = @duplicate_enquiry.create_activity :test
    MergeJob.perform_now @billing_enquiry, @duplicate_enquiry
    
    assert_equal [activity], @billing_enquiry.reload.activities
  end
  
  test "merge labels" do
    @billing_enquiry.update_attribute :labels, %w[ billing ]
    @duplicate_enquiry.update_attribute :labels, %w[ pending ]
    merge = MergeJob.perform_now @billing_enquiry, @duplicate_enquiry
    merge.save
    
    assert_equal %w[ billing pending ], @billing_enquiry.reload.labels
  end
end
