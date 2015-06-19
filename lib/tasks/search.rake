namespace :search do
  desc "Create elasticsearch index"
  task index: :environment do
    Request.all.each  {|_| IndexJob.perform_now(_, :index) }
    Customer.all.each {|_| IndexJob.perform_now(_, :index) }
  end

  desc "Delete elasticsearch index"
  task delete: :environment do
    [Request,Customer].each do |klass|
      klass.__elasticsearch__.client.indices.delete index:klass.index_name
    end
  end
end
