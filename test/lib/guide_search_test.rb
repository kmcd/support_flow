require 'test_helper'

class GuideSearchTest < ActiveSupport::TestCase
  def search(query)
    GuideSearch.new(query).records
  end

  cassette 'indexed_guide_fixtures' do
    test "name" do
      skip
    end
  
    test "content" do
      skip
    end
  end
end
