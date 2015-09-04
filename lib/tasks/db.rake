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
    signup = Login.create email_address:Faker::Internet.safe_email, signup:true

    AgentObserver.class_eval { def after_create(agent); end }
    DemoJob.perform_now signup

    Launchy.open "http://dev.getsupportflow.net/#{signup.team.name}/login?token=#{signup.token}"
  end

  desc "Social proof ids"
  task bump: :environment do
    reset = ->(table, number) {
      ActiveRecord::Base.connection.
        execute "ALTER SEQUENCE #{table.to_s}_id_seq RESTART WITH #{number.to_s};"
    }

    reset[:teams,     10592]
    reset[:agents,    689]
    reset[:customers, 132817]
    reset[:requests,  87304]
    reset[:guides,    4823]
  end
  
  # TODO: pull in getsupportflow.net/help a/c data
end