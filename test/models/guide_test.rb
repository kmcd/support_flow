require 'test_helper'

class GuideTest < ActiveSupport::TestCase
  test "content present" do
    @home_page.content = nil

    refute @home_page.valid?
    assert_match /blank/i, @home_page.errors[:content].first
  end

  test "template yield comment present" do
    @template.content = "<html></html>"

    refute @template.valid?
    assert_equal [ 'must contain content comment <!-- content -->' ],
      @template.errors[:content]
  end

  test "dont create activity for page view" do
    assert_no_difference('Activity.count') do
      @home_page.increment! :view_count
    end
  end
end
