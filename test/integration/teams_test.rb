require 'test_helper'

class TeamsTest < ActionDispatch::IntegrationTest
  test "agent invitation" do
    login @rachel do
      Login.destroy_all
      ActionMailer::Base.deliveries.clear

      get team_agents_path(@support_flow)
      assert_select 'a', href:new_team_agent_path(@support_flow)

      get new_team_agent_path(@support_flow)

      assert_select 'form',
        action:team_agents_path(@support_flow),
        method:/post/i
      assert_select 'input', name:'agent[name]'
      assert_select 'textarea', name:'agent[email_address]'
      assert_select 'button', type:'submit'

      post_via_redirect \
        team_agents_path(@support_flow),
        agent:{name:'agent', email_address:'agent@example.org' }

      new_agent = @support_flow.agents.last
      assert_equal @rachel, new_agent.invitor

      email = ActionMailer::Base.deliveries.last
      assert_equal 1, ActionMailer::Base.deliveries.size

      assert_equal [ new_agent.email_address ], email.to
      assert_equal [ 'rachel@getsupportflow.net' ], email.from

      assert_match /#{@rachel.name}/i, email.subject
      assert_match /#{@rachel.email_address}/i, email.subject
      assert_match /#{@support_flow.name}/i, email.subject
      assert_match /invited.*supportflow/i, email.subject

      assert_match /#{@rachel.name}/i, email.body.to_s
      assert_match /#{@rachel.email_address}/i, email.body.to_s
      assert_match /https:\/\/getsupportflow\.net\/#{@support_flow.name}\/login\/new/i, email.body.to_s
    end
  end

  test "domain name" do
    skip
  end

  test "dashboard number of open requests" do
    skip
    # ensure open request count accurate
    # link to search open requests
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
