class DemoJob < ActiveJob::Base
  attr_reader :login, :team
  queue_as :default

  def perform(login)
    @login = login

    create_team
    create_agents
    create_customers
    create_reply_templates

    active_days do
      create_enquiries
      create_replies
      assign_requests
      label_requests
      rename_requests
      close_requests
      create_guides
      update_guides
    end

    StatisticsJob.perform_now
    login.update team:team
    LoginMailer.signup_email(login).deliver_later
  end

  private

  def create_team
    random_name = ->() { "demo-#{rand(9999..99999)}" }
    @team = Team.new
    @team.name = random_name.call until @team.valid?
    @team.save!
  end

  def create_agents
    team.agents.create \
      email_address:login.email,
      name:login.email[/[^@]*/],
      notification_policy:{ open:false, close:false, assign:false }

    9.times do
      name = [Faker::Name.first_name, Faker::Name.last_name].join(' ')

      team.agents.create \
        email_address: Faker::Internet.safe_email(name),
        name: name,
        phone: Faker::PhoneNumber.phone_number,
        notification_policy:{ open:false, close:false, assign:false }
        # Lorem notes ?
    end
  end

  def create_customers
    100.times do
      name = [Faker::Name.first_name, Faker::Name.last_name].join(' ')

      team.customers.create \
        name: name,
        email_address:Faker::Internet.safe_email(name),
        phone: Faker::PhoneNumber.phone_number,
        labels:labels
        # Lorem notes ?
    end
  end

  def create_enquiries
    team_address = "team.#{team.id}@getsupportflow.net"

    rand(1..10).times do
      enquiry = Faker::Hacker.say_something_smart
      name = [ Faker::Name.first_name, Faker::Name.last_name].join(' ')

      payload = {
        "event": "inbound",
        "ts": 1360822567,
        "msg": {
          "from_email": Faker::Internet.safe_email(name),
          "from_name": name,
          "email": team_address,
          "to": [ [ team_address, nil ] ],
          "subject": enquiry,
          "text": "#{enquiry}\n\n"
        }
      }.to_json

      random_time do
        email = Email::Inbound.create payload:payload
        email.process_payload
      end
    end
  end

  def create_replies
    sample_requests(60..90).each do |request|
      request_address = "request.#{request.id}@getsupportflow.net"
      reply = Faker::Hacker.say_something_smart
      agent = sample_agent

      payload = {
        "event": "inbound",
        "ts": 1360822567,
        "msg": {
          "from_email": agent.email_address,
          "from_name": agent.name,
          "email": request_address,
          "to": [ [ request_address, nil ], [request.customer.email_address, nil] ],
          "subject": reply,
          "text": "#{reply}\n\n"
        }
      }.to_json

      random_time(request.created_at) do
        email = Email::Inbound.create payload:payload
        email.process_payload
      end
    end
  end

  def assign_requests
    sample_requests(60..90).each do |request|
      random_time(request.created_at) do
        request.current_agent = sample_agent
        request.update agent:sample_agent
      end
    end
  end

  def label_requests
    sample_requests(60..90).each do |request|
      random_time(request.created_at) do
        request.current_agent = sample_agent
        request.update labels:labels
      end
    end
  end

  def rename_requests
    sample_requests(15..20).each do |request|
      random_time(request.created_at) do
        request.current_agent = sample_agent
        request.update name:Faker::Hacker.say_something_smart
      end
    end
  end

  def close_requests
    sample_requests(50..70).each do |request|
      next if request.closed?

      random_time(request.created_at) do
        request.current_agent = sample_agent
        request.update open:false
      end
    end
  end

  def create_guides
    team.guides.create \
      name: '_template',
      content: "<html><!-- content --></html>",
      current_agent:sample_agent

    team.guides.create \
      name: 'index',
      view_count: rand(400),
      content: "<h1>Welcome to #{team.name}</h1><p>#{ Faker::Lorem.paragraph(rand(1..10)) }</p>",
      current_agent:sample_agent

    %w[ FAQ Billing Setup Configuration ].each do |page|
      random_time do
        team.guides.create \
          name: page,
          view_count: rand(100),
          content: "<h1>#{page}</h1><p>#{ Faker::Lorem.paragraph(rand(1..10)) }</p>",
          current_agent:sample_agent
      end
    end
  end

  def update_guides
    team.guides.order('random()').take(rand(4)).each do |guide|
      guide.content << "<p>#{ Faker::Lorem.paragraph(rand(1..10)) }</p>"
      guide.current_agent = sample_agent
      
      random_time(guide.created_at) do
        guide.save
      end
    end
  end

  def create_reply_templates
    team.reply_templates.create \
      name: 'Default reply',
      template: <<-TEMPLATE.strip_heredoc
          Hi there!

          Thanks for getting in touch.

          Regards,
          Support Flow team ..."
        TEMPLATE

    team.reply_templates.create \
      name: 'Billing info',
      template: <<-TEMPLATE.strip_heredoc
        Hi there!

        You can read about billing on our help pages: http://getsupportflow.com/help/billing

        Regards,
        Support Flow team ...
      TEMPLATE
  end

  def sample_requests(size=60..90)
    requests_count = team.requests.count
    sample_size = (requests_count/100.0 * size.first).to_i .. \
      (requests_count/100.0 * size.last).to_i

    team.requests.order('random()').take rand(sample_size)
  end

  def sample_agent
    team.agents.order('random()').first
  end

  def labels
    %w[ urgent billing faq pending premium-customer ].sample rand(0..3)
  end

  def active_days
    random_sample = (1..30).
      map {|_| _.days.ago.at_beginning_of_day }.
      sample rand(20..30)

    random_sample = [ 1.day.ago ]

    random_sample.each do |day|
      Timecop.freeze(day) do
        yield
      end
    end
  end

  def random_time(from=0.minutes.ago)
    Timecop.freeze(from + rand(24).hours + rand(60).minutes) do
      yield
    end
  end
end