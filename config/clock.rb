$:.unshift File.join(File.dirname(__FILE__), "..")

require 'config/boot'
require 'config/environment'

module Clockwork
  every 5.minutes, 'sales pipeline' do
    SalesCustomersJob.perform_later
    SalesSyncJob.perform_later
  end

  # TODO: Lots more fun stuff to enqueue:

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