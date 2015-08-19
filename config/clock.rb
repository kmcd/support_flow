$:.unshift File.join(File.dirname(__FILE__), "..")

require 'config/boot'
require 'config/environment'

module Clockwork
  every 5.minutes, 'Updating Statistics' do
    # FIXME: move stats job to observer
    StatisticsJob.perform_now
  end

  # TODO: Lots of fun stuff to enqueue:
  # - Update CRM: signup
  # - Update CRM: trial events (start, setup mailbox etc.)
  # - Update CRM: login
  # - Update CRM: billing
  # - Update app: signup
  # - Update app: trial events (start, setup mailbox etc.)
  # - Update app: login
  # - Update app: billing
  # - Push Log file analysis to GH pages/wiki
end