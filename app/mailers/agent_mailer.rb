class AgentMailer < ApplicationMailer
  def reply(outbound_email)
    build_recipient_list
    set_attachments
    set_html_part
    set_text_part
  end
  
  # Subsequent mailers:
  # command_response
  # enquiry_notification
  # assignment_notification
  # close_notification
  # reopen_notification
  # sla_notification
  
  private
  
  def build_recipient_list
    # outbound_email.recipient_list ...
  end
  
  def set_html_part
  end
  
  def set_text_part
    # Nokogiri::HTML(message_content).text
  end
end
