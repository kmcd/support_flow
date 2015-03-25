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
end
