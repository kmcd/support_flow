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
    cleanup

    login = Login.create email:Faker::Internet.safe_email, signup:true
    DemoJob.perform_now login
    Launchy.open "http://dev.getsupportflow.net/#{login.team.name}/login?token=#{login.token}"
  end
end

def cleanup
  Login.where(signup:true).map(&:team).compact.each do |team|
    team.requests.destroy_all
    team.guides.destroy_all
    team.assets.destroy_all
    team.agents.destroy_all
    team.customers.destroy_all
    team.emails.destroy_all
    team.attachments.destroy_all
    team.logins.destroy_all
    team.reply_templates.destroy_all
    team.destroy
  end
end