require 'active_record/fixtures'
require 'faker'

namespace :db do
  desc "Populate for customer demo"
  task demo: :environment do
    demo_fixture_dir = Rails.root.join 'db', 'fixtures'
    demo_fixtures =  Dir["#{demo_fixture_dir}/*.yml"].
      map {|_| File.basename _, '.yml' }
    ActiveRecord::FixtureSet.create_fixtures demo_fixture_dir, demo_fixtures
  end
end