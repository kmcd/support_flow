require 'test_helper'

class MergeTest < ActiveSupport::TestCase
  test "merge messages" do
    merge = Merge.new @billing_enquiry, @duplicate_enquiry
    merge.save
    
    assert_includes @billing_enquiry.reload.messages, @duplicate
  end
  
  test "delete duplicate messages" do
    duplicate_id = @duplicate_enquiry.id
    merge = Merge.new @billing_enquiry, @duplicate_enquiry
    merge.save
    
    assert_empty Message.where(request_id:duplicate_id).all
  end
  
  test "delete duplicate request" do
    merge = Merge.new @billing_enquiry, @duplicate_enquiry
    merge.save
    
    assert_raises(ActiveRecord::RecordNotFound) { @duplicate_enquiry.reload }
  end
  
  test "merge activities" do
    activity = @duplicate_enquiry.create_activity :test
    merge = Merge.new @billing_enquiry, @duplicate_enquiry
    merge.save
    
    assert_equal [activity], @billing_enquiry.reload.activities
  end
end
