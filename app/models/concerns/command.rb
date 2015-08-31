class Command
  attr_reader :email
  delegate :request, :agent, to: :email

  def initialize(email)
    @email = email
    request.current_agent = agent
  end

  def valid?
    return if agent.blank?
    return if command_arguments.blank?
  end

  def execute
    return if email.request.blank?

    OptionParser.new do |opts|
      opts.on("-a", "--assign AGENT") {|_| assign _ }
      opts.on("-m", "--claim")        {|_| claim    }
      opts.on("-c", "--close")        {|_| close    }
      opts.on("-o", "--open")         {|_| open     }
      opts.on("-r", "--release")      {|_| release  }
      opts.on("-t", "--label NAME")   {|_| label _  }
    end.parse! options

    rescue OptionParser::InvalidOption => error
      # FIXME: email agent with command errors
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
  end

  def claim
    request.update agent:agent
  end

  def close
    request.update open:false
  end

  def open
    request.update open:true
  end

  def release
    request.update agent:nil
  end

  def label(labels)
    request.labels += [labels].flatten
    request.save
  end
end

Request.class_eval do
  def assign_from(name_or_email)
    return unless assignee = team.agents.
      where("name ILIKE ? OR email_address = ?",
      "%#{name_or_email}%", name_or_email ).
      first
    update agent:assignee
  end
end