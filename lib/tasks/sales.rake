namespace :sales do
  desc "Update GSF customer info" # Run as cron job
  task customers: :environment do
    SalesCustomersJob.perform_later
  end

  desc "Sync with sales CRM" # Run as cron job
  task sync: :environment do
    SalesSyncJob.perform_later
  end
end