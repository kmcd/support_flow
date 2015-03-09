require 'optparse'
require 'ostruct'

# USAGE:
# Message contents:
# Hi John, thanks for your help ...
# --status open --reply billing --assign joe --reply
# --status open
# --reply billing
# --assign joe
# --tag billing, problem
# --suggest
# --report daily|weekly|team|agent
# --claim
# --release
# --notify joe

class Command
  attr_reader :message, :errors, :result
  delegate :request, to: :message
  
  def initialize(message)
    @message, @errors = message, []
  end
  
  def execute
    OptionParser.new do |opts|
      opts.on("", "--status STATUS")    {|_| status   _ }
      opts.on("", "--assign AGENT")     {|_| assign   _ }
      opts.on("", "--tag    NAME")      {|_| tag      _ }
      opts.on("", "--reply  [TEMPLATE]"){|_| reply    _ }
      opts.on("", "--report [NAME]")    {|_| report   _ }
      opts.on("", "--claim")            {|_| claim    _ }
      opts.on("", "--release")          {|_| release  _ }
    end.parse! command
    
    rescue OptionParser::InvalidOption => error
      raise error # TODO: handle exceptions & return error messages
  end
  
  private
  
  def command
    # TODO: extract text from html if text part not available
    
    # %w[--tag billing, pending --status open ]
    message.content[/\A\s*(--\w+\s+.+)\Z/m].split /\s+/
    
  end
  
  def status(type)
    # request.update_attributes status:type
  end
  
  def reply(template)
    # Find template
    # DispatchReplyJob.new().perform_later
  end
  
  def assign(agent)
  end
  
  def tag(name)
    request.tags << name
    request.save!
  end
end