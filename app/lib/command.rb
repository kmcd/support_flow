require 'optparse'
require 'ostruct'

# USAGE:
# Message contents:
# Hi John, thanks for your help ...
# --status open --reply billing --assign joe --reply
# --status open
# --reply billing
# Oh forgot to mention, call Peter for more assistance.
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
      opts.on("", "--claim")            {|_| claim      }
      opts.on("", "--release")          {|_| release    }
    end.parse! command
    
    rescue OptionParser::InvalidOption => error
      errors << error
  end
  
  private
  
  def command
    # TODO: extract text from html if text part not available
    # TODO: refactor to StringScanner mini parser
    message.content.
      split(/\n/).
      find_all {|_| _[/\A\s*--\w+.*\Z/] }.
      join.
      split(/(--[A-Za-z]+)/)[1..-1].
      each_slice(2).
      to_a.
      flatten.
      map &:strip
  end
  
  def status(type)
    # request.update_attributes status:type
  end
  
  def reply(template)
    # Find template
    # DispatchReplyJob.new().perform_later
  end
  
  def assign(name_or_email)
    return unless assigned_agent = request.agent.team.agents.
      where("email_address SIMILAR TO ? OR email_address = ?",
        "%#{name_or_email}%@%", name_or_email ).
      first
    
    request.agent = assigned_agent
    request.save!
  end
  
  def claim
    return unless valid_agent?
    return unless request.agent = message.agent
    request.save!
  end
  
  def release
    return unless valid_agent?
    request.agent = nil
    request.save!
  end
  
  def tag(names)
    seperator = /(\s|,)/
    names.split(seperator).
      reject {|_| _[seperator] || _.blank? }.
      map(&:downcase).
      each {|tag| request.tags << tag unless request.tags.include?(tag) }
    request.save!
  end
  
  def valid_agent?
    request.agent.team.agents.include? message.agent
  end
end