class Command
  attr_reader :email
  delegate :request, :agent, to: :email

  def initialize(email)
    @email = email
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
    Activity.assign request, agent
  end

  def claim
    request.update_attributes! agent:agent
    Activity.assign request, agent
  end

  def close
    request.update_attributes! open:false
    Activity.close request, agent
  end

  def open
    request.update_attributes! open:true
    Activity.open request, agent
  end

  def release
    request.update_attributes! agent:nil
    Activity.assign request, agent
  end

  def label(labels)
    request.labels += [labels].flatten
    request.save
    Activity.label request, agent, [labels].flatten
  end
end