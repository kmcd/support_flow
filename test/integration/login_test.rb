require 'test_helper'

class LoginTest < ActionDispatch::IntegrationTest
  def setup
    host! 'getsupportflow.net'
  end

  test "valid agent login" do
    Login.destroy_all
    ActionMailer::Base.deliveries.clear

    get new_team_login_path(@support_flow.name)
    assert_response :success

    assert_select('form', method:'post', action:team_login_path(@support_flow.name)) do
      assert_select 'input',  type:'text', name:'login[email]'
      assert_select 'button', type:'submit'
    end

    post team_login_path(@support_flow.name), login:{email_address:@rachel.email_address}
    assert_response :success

    assert_match /login.*link/, response.body.to_s
    assert_match /#{@rachel.email_address}/, response.body.to_s

    assert_equal 1, Login.count
    assert_equal 1, ActionMailer::Base.deliveries.size

    email = ActionMailer::Base.deliveries.first
    login = Login.last

    assert_equal @rachel.email_address, login.email_address
    assert_equal %w[ rachel@getsupportflow.net ], email.from
    assert_equal [ @rachel.email_address ], email.to
    assert_match /login/i, email.subject
    assert_match /http:\/\/getsupportflow.net\/#{login.team.name}\/login\?token=#{login.token}/, email.body.to_s

    get team_login_url(@rachel.team), token:login.token
    assert_redirected_to team_url(@support_flow.name)
  end

  test "ignore invalid email login credentials" do
    ActionMailer::Base.deliveries.clear
    host! 'getsupportflow.net'
    post team_login_path(@support_flow.name), login:{email:'bogus@example.org'}

    assert_redirected_to new_team_login_path(@support_flow.name)
    assert_equal 0, Login.count
    assert_equal 0, ActionMailer::Base.deliveries.size
  end

  test "agent team authorisation" do
    login @peldi do
      get_via_redirect team_url(@support_flow.name)
      assert_response 404
    end
  end

  test "agent email command authorisation" do
    command = @command
    command.payload['msg']['from_email'] = @peldi.email_address
    command.payload['msg']['text'] = "--close"
    payload = { mandrill_events:[command.payload].to_json }

    assert @billing_enquiry.open?

    anonymous do
      post '/email/inbound', payload
      assert_response :ok
    end

    assert_not @billing_enquiry.reload.closed?
  end

  test "expire login token after 5 minutes" do
    skip
  end

  test "ignore invalid team name" do
    skip
  end

  test "logout" do
    skip
  end
end
