require 'test_helper'

class RequestTest < ActiveSupport::TestCase
  test "dont add duplicate tags" do
    @billing_enquiry.tags = %w[ billing billing ]
    @billing_enquiry.save
    assert_equal %w[ billing ], @billing_enquiry.tags
    
    @billing_enquiry.tags << %w[ billing ]
    @billing_enquiry.save
    assert_equal %w[ billing ], @billing_enquiry.tags
  end
  
  test "tags are always lower case" do
    @billing_enquiry.tags = %w[ BILLING ]
    @billing_enquiry.save
    assert_equal %w[ billing ], @billing_enquiry.tags
  end
end
