require 'test_helper'

class GuideTest < ActiveSupport::TestCase
  test "name must not contain forward slashes" do
    @faq.name = "faq/questions"
    refute @faq.valid?
  end
  
  test "name must not contain back slash" do
    @faq.name = 'about\us'
    refute @faq.valid?
  end
end
