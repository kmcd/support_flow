require 'launchy'

namespace :app do
  desc "Populate with demo a/c data"
  task login: :environment do
    agent = Agent.last
    login = Login.new team:agent.team, email_address:agent.email_address
    login.instance_eval { def dispatch_email; end }
    login.save!

    Launchy.open "http://dev.getsupportflow.net/#{login.team.name}/login?token=#{login.token}"
  end
end
