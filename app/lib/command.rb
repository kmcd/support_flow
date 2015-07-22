class Command
  attr_reader :activity, :email
  delegate :request, :agent, to: :email
  
  def initialize(email)
    @email = email
    @activity = Activity.new request:request, owner:agent
  end
  
  def valid?
    agent.present? && command_arguments.present?
  end
  
  def execute
    return unless email.request.present?

    OptionParser.new do |opts|
      opts.on("-a", "--assign AGENT") {|_| command.assign _ }
      opts.on("-m", "--claim")        { command.claim }
      opts.on("-c", "--close")        { command.close }
      opts.on("-o", "--open")         { command.open }
      opts.on("-r", "--release")      { command.release }
      opts.on("-t", "--label NAME")   {|_| command.label _ }
    end.parse! options

    rescue OptionParser::InvalidOption => error
      errors << error # TODO: handle request errors
  end
  
  private
  
  def options
    email.message.command_arguments.
      split(/(-{1,2}[A-Za-z]+)/)[1..-1].
      each_slice(2).
      to_a.
      flatten.
      map &:strip
  end
  
  def assign(name_or_email)
    request.assign_from name_or_email
    activity.assign request.agent
  end
  
  def claim
    request.update_attributes! agent:agent
    activity.assign agent
  end
  
  def close
    request.update_attributes! open:false
    activity.close
  end
  
  def open
    request.update_attributes! open:true
    activity.open
  end
  
  def release
    request.update_attributes! agent:nil
    activity.assign
  end
  
  def label(labels)
    request.update label:labels
    activity.label labels
  end
end