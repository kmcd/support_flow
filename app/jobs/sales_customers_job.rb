class SalesCustomersJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    support_flow = Team.where(name:'help').first

    Agent.support_flow_customers.last_5_mins.each do |agent|
      labels = []
      labels << 'demo' if agent.team.demo?
      labels << 'trial' if agent.team.trial?

      customer = support_flow.customers.
        where(email_address:agent.email_address).
        first_or_create

      notes = customer.notes || ""
      app_links = <<-NOTES.strip_heredoc
        team:   https://getsupportflow.net/#{agent.team.name} <br/>
        agent:  https://getsupportflow.net/agents/#{agent.id} <br/>
        campaign: https://support-flow-sales.herokuapp.com/campaigns/1 <br/>
      NOTES

      notes << Rinku.auto_link(app_links)

      customer.update \
        name:agent.name,
        labels:labels,
        notes:notes
    end
  end
end
