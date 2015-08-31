require 'test_helper'

class SignupTest < ActionDispatch::IntegrationTest
  test "dispatch email with login token" do
    Login.destroy_all
    ActionMailer::Base.deliveries.clear
    Agent.any_instance.stubs(:dispatch_invitation)

    host! 'getsupportflow.net'
    get new_signup_url
    assert_response :success

    assert_select('form', method:'post', action:signup_url) do
      assert_select 'input',  type:'text', name:'login[email]'
      assert_select 'button', type:'submit'
    end

    signup_email = 'signup@example.org'
    post signup_url, login:{email_address:signup_email}
    assert_response :success

    assert_equal 1, Login.count
    login = Login.last
    assert_equal signup_email, login.email_address
    assert_match /#{login.email_address}/, response.body.to_s

    email = ActionMailer::Base.deliveries.first

    assert_equal [signup_email], email.to
    assert_equal ['rachel@getsupportflow.net'], email.from
    assert_match /http:\/\/getsupportflow.net\/#{login.team.name}\/login\?token=#{login.token}/, email.body.to_s

    get team_login_url(@rachel.team), token:login.token
    assert_redirected_to team_url(@support_flow.name)
  end

  test "create demo account" do
    skip
  end
end

DemoJob.class_eval do
  def active_days
    Timecop.freeze(1.day.ago.at_beginning_of_day) { yield }
  end

  private

  def sample_size
    {
      agents:1,
      customers:1,
      enquiries:rand(0..1),
      replies:0..1,
      assign:0..1,
      rename:0..1,
      label:0..1,
      close:0..1
    }
  end
end
