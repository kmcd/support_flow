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
end
