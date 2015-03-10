namespace :db do
  desc "Populate database with break even number of agents"
  task populate: :environment do
    # TODO: load fixtures from db/data/breakeven/(agents|customers|...).yml
    
    # Create:
    #   -> 630 agents
    #   -> teams of 1 - 10 agents using random sampling
    #   -> 365 * 60 requests for each team
    #   -> request activity
    #   -> 365 * 60 * 10 search entries
  end
  
  desc "Populate database with demo"
  task demo: :environment do
    # TODO: load fixtures from db/data/demo/(agents|customers|...).yml
  end
end