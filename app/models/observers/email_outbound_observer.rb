class EmailOutboundObserver < ActiveRecord::Observer
  observe Email::Outbound

  def after_create(email)
    email.mailer.deliver_later
  end
end

Email::Outbound.class_eval do
  def mailer
    if team.demo?
      AgentMailer.demo_reply self
    else
      AgentMailer.reply self
    end
  end
end