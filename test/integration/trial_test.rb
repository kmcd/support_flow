require 'test_helper'

class TrialTest < ActionDispatch::IntegrationTest
  test "start trial" do
    login @rachel do
      # assert start trial link
      assert_select 'a', href:new_team_trial_path(@support_flow)

      # click start trial
      get new_team_trial_path(@support_flow)
      assert_response :success

      # assert start trial form
      assert_select('form', method:'post', action:team_trial_path(@support_flow)) do
        assert_select 'input',  type:'text', name:'trial[team_name]'
        assert_select 'button', type:'submit'
      end

      # sumbit start trial form
      team_name = 'support-flow-trial'
      post team_trial_path(@support_flow), trial:{team_name:team_name}
      assert_redirected_to team_trial_path(team_name)

      # assert team subscription
      @support_flow.reload
      assert_equal team_name, @support_flow.name
      assert @support_flow.trial?

      # TODO: improve assert demo data removed
      assert @support_flow.customers.where(name:/example/i).empty?

      # assert 1st welcome request
      welcome = @support_flow.requests.last

      assert_equal 'rachel@getsupportflow.net', welcome.customer.email_address
    end
  end
end
