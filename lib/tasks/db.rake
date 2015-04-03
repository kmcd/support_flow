namespace :db do
  desc "Populate with break even number of agents"
  task populate: :environment do
    # TODO: load fixtures from db/data/breakeven/(agents|customers|...).yml
    
    # Create:
    #   -> 630 agents
    #   -> teams of 1 - 10 agents
    #   -> 365 * 60 requests for each team
    #   -> request activity
    #   -> 365 * 60 * 10 search entries
  end
  
  desc "Populate for customer demo"
  task demo: :environment do
    # TODO: load fixtures from db/data/demo/(agents|customers|...).yml
  end
  
  desc "Populate for UI development"
  task ui: [:environment, 'db:schema:load', 'db:fixtures:load'] do
    rachel = Agent.first
    peldi = Customer.first
    
    create_message \
      body:'Hi! I need help with billing. Peldi',
      subject:'Help',
      from:peldi.email_address,
      to:rachel.team.mailboxes.first.email_address
    
    request = Request.where(name:"Billing enquiry").first
    
    create_message \
      body:"We're on it Peldi :)",
      subject:'Help',
      from:rachel.team.mailboxes.first.email_address,
      to:peldi.email_address,
      cc:"request.#{request.id}@getsupportflow.com"
      
    create_message \
      body:'--assign keith',
      from:rachel.email_address,
      to:"request.#{request.id}@getsupportflow.com"
    
    create_message \
      body:'--label billing',
      from:rachel.email_address,
      to:"request.#{request.id}@getsupportflow.com"
      
    create_message \
      body:'--close',
      from:rachel.email_address,
      to:"request.#{request.id}@getsupportflow.com"
    
    # Message:
    # - above fold reply
    # - html only
    # - text only
    
    # - merge
    # - rename
    # - reopen
    
    [ Request.all, Message.all ].flatten.each do |_|
      UpdateSearchIndexJob.perform_now _, _.attributes.to_json
    end
  end
end

def create_message(to:, from:, subject:'', body:, cc:[])
  EmailProcessorJob.new.perform Griddler::Email.new( \
    to:[to], from:from, subject:subject, text:body, cc:[cc].flatten )
end