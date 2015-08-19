require 'test_helper'

class StatisticsTest < ActionDispatch::IntegrationTest
  def setup
    ApplicationController.stubs(:current_agent).returns @rachel
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
  
  test "request waiting time" do
    skip
    # time passes
    # ensure request waiting time up to date
  end
  
  test "request first reply" do
    skip
    # reply to request
    # ensure first reply time calculation correct
  end
  
  test "agent first reply" do
    skip
    # reply to 
    # ensure first reply time calculation correct
  end
  
  test "agent customer happiness" do
    skip
    # reply to 
    # ensure first reply time calculation correct
  end
  
  test "agent average close" do
    skip
    # reply to 
    # ensure first reply time calculation correct
  end
  
  test "customer first reply" do
    skip
    # reply to 
    # ensure first reply time calculation correct
  end
  
  test "customer happiness" do
    skip
    # reply to 
    # ensure first reply time calculation correct
  end
  
  test "customer average close" do
    skip
    # reply to 
    # ensure first reply time calculation correct
  end
end
