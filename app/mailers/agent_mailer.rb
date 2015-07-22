class AgentMailer < ApplicationMailer
  def reply(outbound_email)
    add_attachments outbound_email

    mail envelope(outbound_email) do |format|
      format.html { outbound_email.message_content }
      format.text { Nokogiri::HTML(outbound_email.message_content).text }
    end
  end

  private

  def envelope(outbound_email)
    { from:outbound_email.sender.email_address,
      to:outbound_email.recipient_list.to,
      cc:outbound_email.recipient_list.cc,
      bcc:bcc_recipients(outbound_email),
      subject:outbound_email.request.name }
  end

  def add_attachments(outbound_email)
    outbound_email.attachments.each_with_object({}) do |file, attachment|
      attachments[file.name] = file.content
    end
  end

  def bcc_recipients(outbound_email)
    request_address = "request.#{outbound_email.request.id}@getsupportflow.net"
    [ outbound_email.recipient_list.bcc, request_address ].flatten
  end
end

# Subsequent mailers:
# command_response
# enquiry_notification
# assignment_notification
# close_notification
# reopen_notification
# sla_notification
