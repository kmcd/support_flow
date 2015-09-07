class SalesSyncJob < ActiveJob::Base
  SALES_DB = Sequel.connect "postgres://xdukemdiocmvih:kg6aasRN7aj2YWALNOhIltdj_N@ec2-54-217-202-109.eu-west-1.compute.amazonaws.com:5432/d44t623isgoibt"
  queue_as :default

  def perform(*args)
    sync_leads
    sync_opportunities
    sync_ratings
  end
  
  def sync_leads
    leads.each do |agent|
      lead_id = SALES_DB[:leads].insert \
        email:agent.email_address,
        first_name:"#{ agent.name || 'agent' }",
        last_name:"##{agent.id}",
        campaign_id:agent.campaign_id,
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago

      SALES_DB[:comments].insert \
        user_id:1,
        commentable_type:'Lead',
        commentable_id:lead_id,
        comment:"http://getsupportflow.net/#{agent.team.name}",
        state:'Expanded',
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago

      contact_id = SALES_DB[:contacts].insert \
        email:agent.email_address,
        first_name:"#{ agent.name || 'agent' }",
        last_name:"##{agent.id}",
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago

      SALES_DB[:comments].insert \
        user_id:1,
        commentable_type:'Contact',
        commentable_id:contact_id,
        comment:"http://getsupportflow.net/#{agent.team.name}",
        state:'Expanded',
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago
      end
    end
  end
  
  def sync_opportunities
    opportunities.each do |agent|
      SALES_DB[:leads].
        where( email:agent.email_address ).
        update status:'converted'

      account_id = SALES_DB[:accounts].insert \
        name:"##{agent.team.id} #{agent.team.name}",
        category:'Customer',
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago

      SALES_DB[:comments].insert \
        user_id:1,
        commentable_type:'Account',
        commentable_id:account_id,
        comment:"http://getsupportflow.net/#{agent.team.name}",
        state:'Expanded',
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago

      opportunity_id = SALES_DB[:opportunities].insert \
        name:"##{agent.team.id} #{agent.team.name} TRIAL",
        stage:'trial',
        campaign_id:agent.campaign_id,
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago

      SALES_DB[:account_opportunities].insert \
        account_id:account_id,
        opportunity_id:opportunity_id,
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago

      SALES_DB[:comments].insert \
        user_id:1,
        commentable_type:'Opportunity',
        commentable_id:opportunity_id,
        comment:"http://getsupportflow.net/#{agent.team.name}",
        state:'Expanded',
        created_at:0.minutes.ago,
        updated_at:0.minutes.ago
    end
  end
  
  def sync_ratings
    ratings.each do |address, rating|
      SALES_DB[:leads].where(email:address).update rating:rating
    end
  end
  
  def leads
    Agent.
      support_flow_customers.
      demo.
      last_5_mins
  end
  
  def opportunities
    Agent.
      support_flow_customers.
      trial.
      last_5_mins.
      group_by(&:team_id).
      map {|_, agents| agents.first }
  end
  
  def ratings
    Login.group(:email_address).count.map do |address, count|
      rating = count > 5 ? 5 : count
      [ address, rating ]
  end
end

Agent.class_eval do
  scope :demo, ->() {
    joins(:team).
    where( teams:{subscription:0} )
  }

  scope :trial, ->() {
    joins(:team).
    where( teams:{subscription:1} )
  }

  def campaign_id
    Login.
      where(email_address:email_address).
      where('campaign IS NOT NULL').
      first.campaign
  end
end
