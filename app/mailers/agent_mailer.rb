class AgentMailer < ApplicationMailer
  # TODO: split out into Command, CustomerReply, Invitation mailers

  def reply(outbound_email)
    add_attachments outbound_email

    mail envelope(outbound_email) do |format|
      format.html { outbound_email.message_content }
      format.text { Nokogiri::HTML(outbound_email.message_content).text }
    end
  end

  def demo_reply(outbound_email)
    @outbound_email = outbound_email
    add_attachments outbound_email

    mail \
      from:request_address(outbound_email.request),
      to:outbound_email.sender.email_address,
      cc:request_address(outbound_email.request),
      subject:subject_line(outbound_email.request, :demo)
  end

  def invitation(agent)
    @agent = agent
    mail to:agent.email_address
  end

  def open(agent, request)
    @agent, @request = agent, request

    mail \
      from:request_address(request),
      to:agent.email_address,
      subject:subject_line(request, :opened)
  end

  def assign(agent, request)
    @agent, @request = agent, request

    mail \
      from:request_address(request),
      to:agent.email_address,
      subject:subject_line(request, :assigned)
  end

  def close(agent, request)
    @agent, @request = agent, request

    mail \
      from:request_address(request),
      to:agent.email_address,
      subject:subject_line(request, :closed)
  end

  private

  def envelope(outbound_email)
    {
      from:outbound_email.sender.email_address,
      to:outbound_email.recipient_list.to,
      cc:outbound_email.recipient_list.cc,
      bcc:bcc_recipients(outbound_email),
      subject:outbound_email.request.name
    }
  end

  def add_attachments(outbound_email)
    outbound_email.attachments.each_with_object({}) do |file, attachment|
      attachments[file.name] = file.content
    end
  end

  def bcc_recipients(outbound_email)
    [ outbound_email.recipient_list.bcc,
      request_address(outbound_email.request) ].flatten
  end

  def request_address(request)
    "request.#{request.id}@getsupportflow.net"
  end

  def subject_line(request, operation)
    "[getsupportflow/#{request.team.name}] Request ##{request.id} #{operation.to_s}"
  end
end

# TODO: push down to decorator - e.g.
#   module OutboundEmailMailer
#     def request_address
#       "request.#{request.id}@getsupportflow.net"
#     end
#   end
# outbound_email.extend OutboundEmailMailer
