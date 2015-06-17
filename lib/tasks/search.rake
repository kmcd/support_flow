namespace :search do
  desc "Create elasticsearch index"
  task index: :environment do
    Request.all.each  {|_| IndexJob.perform_now(_, :index) }
    Customer.all.each {|_| IndexJob.perform_now(_, :index) }
  end

  desc "Delete elasticsearch index"
  task delete: :environment do
    Request.all.each  {|_| IndexJob.perform_now(_, :delete) }
    Customer.all.each {|_| IndexJob.perform_now(_, :delete) }
  end
end
