class EnquiryJob < ActiveJob::Base
  TEAM_EMAIL_REGEX = /team\.(\d+)@getsupportflow.net/
  attr_reader :email, :request
  queue_as :default
  
  def perform(email)
    @email = email
    return unless valid?
    assign_request
    assign_customer
    # update_activity_stream
  end
  
  private
  
  def valid?
    return if reply_to_existing_request?
    team.present?
  end
  
  def assign_request
    @request = email.create_request emails_count:1, team:team
  end
  
  def assign_customer
    return if agent_enquiry?
    request.customer = existing_customer || new_customer
    request.save!
  end
  
  def existing_customer
    team.customers.where(email_address:from).first
  end
  
  def new_customer
    team.customers.create! email_address:from
  end
  
  def update_activity_stream
    Activity.new(request:request, owner:customer).enquiry email
  end
  
  def team
    return unless email.to.match TEAM_EMAIL_REGEX
    team_id = TEAM_EMAIL_REGEX.match(email.to)[1]
    @team ||= Team.find team_id
  end
  
  def from
    email.from
  end
  
  def agent_enquiry?
    team.agents.map(&:email_address).include?(from)
  end
  
  def reply_to_existing_request?
    email.message.recipient_addresses.any? do |address|
      /request\.(\d+)@getsupportflow.net/.match address
    end
  end
end
