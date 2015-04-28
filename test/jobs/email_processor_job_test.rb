require 'test_helper'

class EmailProcessorJobTest < ActiveJob::TestCase
  # TODO: ensure called with json & passed on to Enquiry, Reply, Command
  # (or alter Enquiry, Reply, Command initialize with json)
end
