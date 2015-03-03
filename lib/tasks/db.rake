namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    
    # Setup a support team
    team = Team.create
    agent = team.agents.create email_address:Faker::Internet.safe_email
    mailbox = team.mailboxes.create email_address:Faker::Internet.
      safe_email('support'), credentials:''
    
    # Create support requests
    # TODO: unit test callback, queueing logic, events etc.
    mailbox.messages.create content:'Foo'
    
    # Create request activity
    # e.g. assign to team member, close, re-open etc.
    
    # Create guides
    
    # Populate team stats
  end
  
  desc "Fill database with enough customers to break even"
  task breakeven: :environment do
    # Create:
    #   -> 630 agents
    #   -> teams of 1 - 10 agents using random sampling
    #   -> 365 * 60 requests for each team
    #   -> request activity
    #   -> 365 * 60 * 10 search entries
  end
end