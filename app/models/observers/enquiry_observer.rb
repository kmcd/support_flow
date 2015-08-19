class EnquiryObserver < ActiveRecord::Observer
  observe Email::Inbound

  def after_create(email)
    email.associate_request
    email.associate_agent
    email.associate_customer
    email.enquiry_activity
  end
end

Email::Inbound.class_eval do
  delegate :from, :subject, to: :message

  def associate_request
    request = addressed_to_request || \
      create_request(team:team, name:subject, emails_count:1)

    update request:request
  end

  def associate_agent
    update sender:agent if from_agent?
  end

  def associate_customer
    return if from_agent?

    customer = existing_customer || create_customer
    request.update(customer:customer) if request.customer.blank?
    update sender:customer
  end

  def enquiry_activity
    return unless request.enquiry?

    request.create_activity :open, owner:sender,
      parameters:{ 'email_id' => id }
  end

  private

  def agent
    Agent.where(email_address:from, team:team).first
  end

  def existing_customer
    Customer.where(email_address:from, team:team).first
  end

  def create_customer
    Customer.create email_address:from, name:from, team:team
  end
end

Request.class_eval do
  def enquiry?
    Activity.where(key:'request.open', trackable:self).empty?
  end
end
