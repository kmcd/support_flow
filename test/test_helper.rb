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
        from:'customer@example.org',
        text:"Help"
      }.merge!(options) )
  end
end

module CommandTestable
  def execute(command, options={})
    args = {
      text:command,
      to:%W[ request.#{@billing_enquiry.id}@getsupportflow.net ], 
      from:@billing_enquiry.agent.email_address
    }.merge! options
    
    command = Command.new Griddler::Email.new args
    command.execute
    command
  end
end
