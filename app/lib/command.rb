require 'optparse'

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
      opts.on("", "--status STATUS") do |status|
        request.update_attributes status:status
      end
      
      opts.on("", "--claim") do
        request.update_attributes! agent:agent
      end
      
      opts.on("", "--release") do
        request.update_attributes! agent:nil
      end
      
      opts.on("", "--assign AGENT") do |name_or_email|
        request.assign_from name_or_email
      end
      
      opts.on("", "--tag NAME") do |tags|
        request.tag_with tags
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
    mailbox.team.agents.where(email_address:from).first
  end
  
  def arguments
    email.raw_text.
      split(/\n/).
      find_all {|_| _[/\A\s*--\w+.*\Z/] }.
      join.
      strip
  end
end