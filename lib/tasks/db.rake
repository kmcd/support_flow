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
    
    create_email \
      body:'Hi! I need help with billing. Peldi',
      subject:'Help',
      from:peldi.email_address,
      to:rachel.team.mailboxes.first.email_address
    
    request = Request.where(name:"Billing enquiry").first
    request.update label:'urgent'
    
    create_email \
      body:"We're on it Peldi :)",
      subject:'Help',
      from:rachel.team.mailboxes.first.email_address,
      to:peldi.email_address,
      cc:"request.#{request.id}@getsupportflow.com"
    
    create_email \
      body:'--assign keith',
      from:rachel.email_address,
      to:"request.#{request.id}@getsupportflow.com"
    
    create_email \
      body:'--label billing',
      from:rachel.email_address,
      to:"request.#{request.id}@getsupportflow.com"
      
    create_email \
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
  end
end

def create_email(to:, from:, subject:'', body:, cc:[])
  EmailProcessorJob.new.perform Griddler::Email.new( \
    to:[to], from:from, subject:subject, text:body, cc:[cc].flatten )
end