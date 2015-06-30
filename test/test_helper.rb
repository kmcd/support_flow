ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'mocha/mini_test'
require 'vcr'

Minitest::Reporters.
  use! [Minitest::Reporters::SpecReporter.new]

VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

class ActiveSupport::TestCase
  fixtures :all
  self.use_instantiated_fixtures = true
  
  def setup
    IndexJob.any_instance.stubs :index
    IndexJob.any_instance.stubs :update
    IndexJob.any_instance.stubs :delete
  end
end

# FIXME: why is this not available to ActiveSupport::TestCase sub classes?
def cassette(name, options={})
  VCR.use_cassette(name, options) { yield }
end
