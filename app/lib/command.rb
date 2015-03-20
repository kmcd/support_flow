require 'optparse'

# USAGE:
# Message contents:
# Hi John, thanks for your help ...
# --reply billing --assign joe --reply
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
  include Mailboxable
  attr_reader :email, :errors
  
  def initialize(email=Griddler::Email.new)
    @email = email
    @errors = []
  end
  
  def valid?
    return unless agent.present?
    return unless arguments.present?
    request.present? # TODO: remove - request not always required, e.g. report
  end
  
  def execute
    return unless valid?
    
    OptionParser.new do |opts|
      opts.on("-a", "--assign AGENT") do |name_or_email|
        request.assign_from name_or_email
        activity.assign request.agent
      end
      
      opts.on("-m", "--claim") do
        request.update_attributes! agent:agent
        activity.assign agent
      end
      
      opts.on("-c", "--close") do
        request.update_attributes! open:false
        activity.close
      end
      
      opts.on("-o", "--open") do
        request.update_attributes! open:true
        activity.open
      end
      
      opts.on("-r", "--release") do
        request.update_attributes! agent:nil
        activity.assign
      end
      
      opts.on("-t", "--tag NAME") do |tags|
        request.tag_with tags
        activity.tag tags
      end
    end.parse! options
    
    rescue OptionParser::InvalidOption => error
      errors << error # TODO: handle request errors
  end
  
  private
  
  def options
    return [] unless arguments.present?
      
    arguments.
      split(/(--[A-Za-z]+)/)[1..-1].
      each_slice(2).
      to_a.
      flatten.
      map &:strip
  end
  
  def request
    Reply.new(email).request
  end
  
  def agent
    return unless mailbox.present?
    @agent ||= mailbox.team.agents.where(email_address:from).first
  end
  
  def arguments
    email.raw_text.
      split(/\n/).
      find_all {|_| _[/\A\s*--\w+.*\Z/] }.
      join.
      strip
  end
  
  def activity
    Activity.new request:request, owner:agent
  end
end