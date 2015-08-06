namespace :search do
  desc "Create elasticsearch index"
  task index: :environment do
    [ Request, Customer, Guide ].each do |klass|
      klass.all.each  {|_| IndexJob.perform_now(_, :index) }
    end
  end

  desc "Delete elasticsearch index"
  task delete: :environment do
    [ Request, Customer, Guide ].each do |klass|
      begin
        klass.__elasticsearch__.client.indices.delete index:klass.index_name
      rescue Elasticsearch::Transport::Transport::Errors::NotFound
      end
    end
  end
end
