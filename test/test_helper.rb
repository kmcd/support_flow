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

# TODO: move to email_command fixture
module CommandTestable
  def execute(command, options={})
    args = {
      text:command,
      to:%W[ request.#{@billing_enquiry.id}@getsupportflow.net ], 
      from:@billing_enquiry.agent.email_address
    }.merge! options
    
    command = Command.new Email.new args
    command.execute
    command
  end
end
