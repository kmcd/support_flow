require 'active_record/fixtures'
require 'faker'
require 'launchy'

namespace :db do
  desc "Populate for UI testing"
  task ui: :environment do
    demo_fixture_dir = Rails.root.join 'db', 'fixtures'
    demo_fixtures =  Dir["#{demo_fixture_dir}/*.yml"].
      map {|_| File.basename _, '.yml' }
    ActiveRecord::FixtureSet.create_fixtures demo_fixture_dir, demo_fixtures
  end

  desc "Populate with demo a/c data"
  task demo: :environment do
    SignupObserver.class_eval { def after_create(login); end }
    signup = Login.create email:Faker::Internet.safe_email, signup:true

    AgentObserver.class_eval { def after_create(agent); end }
    DemoJob.perform_now signup

    Launchy.open "http://dev.getsupportflow.net/#{signup.team.name}/login?token=#{signup.token}"
  end
end