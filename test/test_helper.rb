ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'mocha/mini_test'

Minitest::Reporters.
  use! [Minitest::Reporters::SpecReporter.new]

class ActiveSupport::TestCase
  fixtures :all
  self.use_instantiated_fixtures = true
end

ActionDispatch::IntegrationTest.class_eval do
  def login(agent, &activity)
    open_session do |session|
      login = Login.create email:agent.email_address, team:agent.team
      host! 'getsupportflow.net'
      session.get_via_redirect team_login_url(agent.team), token:login.token
      session.instance_eval &activity
    end
  end

  def anonymous(&activity)
    open_session do |session|
      session.instance_eval &activity
    end
  end
end
