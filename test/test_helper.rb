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
  
  def email_attributes(args)
    { to:[ @support_flow_gmail.email_address ], 
      from:@peldi.email_address,
      subject:'Help', 
      body:'Help!' }.merge!(args)
  end
  
  def create_message(args={})
    Message.create content:Griddler::Email.new(email_attributes(args)),
      mailbox:@support_flow_gmail
  end
end
