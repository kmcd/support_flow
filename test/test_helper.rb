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
  
  def email(options={})
    Griddler::Email.new( \
      { to:[@support_flow_gmail.email_address],
      from:'customer@example.org' }.merge!(options) )
  end
end
