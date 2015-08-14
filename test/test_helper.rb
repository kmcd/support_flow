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
  
  def setup
    # TODO: move to observers
    IndexJob.any_instance.stubs :index
    IndexJob.any_instance.stubs :update
    IndexJob.any_instance.stubs :delete
  end
end
