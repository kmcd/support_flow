class CommandObserver < ActiveRecord::Observer
  observe Email::Inbound
  
  def after_create(email)
    email.process_commands
  end
end

Email::Inbound.class_eval do
  def process_commands
    return unless from_agent?
    return unless message.command_arguments.present?

    Command.new(self).execute
  end
end
