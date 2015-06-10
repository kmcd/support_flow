require 'optparse'

class CommandJob < ActiveJob::Base
  attr_reader :email, :errors
  queue_as :default

  def perform(email)
    initialise email
    return unless valid?
    execute_command
    self
  end

  private

  def initialise(email)
    @email, @errors = email, []
    email.associate_request
  end

  def valid?
    email.agent.present? && email.command_arguments.present?
  end

  def execute_command
    return unless email.request.present?
    command = Command.new email

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

  def options
    email.command_arguments.
      split(/(-{1,2}[A-Za-z]+)/)[1..-1].
      each_slice(2).
      to_a.
      flatten.
      map &:strip
  end
end
