require 'test_helper'

class TeamsTest < ActionDispatch::IntegrationTest
  test "domain name" do
    skip
  end
  
  test "validations" do
    skip
    # name
  end
  
  test "dashboard number of open requests" do
    get team_path(@support_flow)
    # ensure open request count accurate
  end
  
  test "dashboard average first reply" do
    skip
    # reply to a request
    # ensure open requests incremented
    # close request
    # ensure open requests decremented
  end
  
  test "dashboard average close" do
    skip
    # close request
    # ensure average close updated
  end
  
  test "dashboard customer happiness" do
    skip
    # update request customer happiness
    # ensure dashboard customer happiness updated
  end
end
