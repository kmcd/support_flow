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
  attr_reader :request, :command, :errors, :result
  
  def initialize(message)
    @request = message.request
    @command = extract message.content
    @errors = []
  end
  
  def execute
    opt_parser = OptionParser.new do |opts|
      opts.on("", "--status STATUS")    {|_| status   _ }
      opts.on("", "--assign AGENT")     {|_| assign   _ }
      opts.on("", "--tag    NAME")      {|_| tag      _ }
      opts.on("", "--reply  [TEMPLATE]"){|_| reply    _ }
      opts.on("", "--report [NAME]")    {|_| report   _ }
      opts.on("", "--claim")            {|_| claim    _ }
      opts.on("", "--release")          {|_| release  _ }
    end.parse! command
    
    rescue OptionParser::InvalidOption => error
      # TODO: handle exceptions & return error messages
  end
  
  private
  
  def extract(message_content)
    # Use text part; if text part not available, extract text from html
    # @command = message_content[/REGEX/]
    # add_extra_dash for OptionParser
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
end