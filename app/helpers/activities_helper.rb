module ActivitiesHelper
  # TODO: delegate methods to ActivityView
  # ActivityView.new activity
  # activity.message_content(emails)
  # activity.description
  
  def message_content(activity, emails)
    return unless emails
    return unless email_id = activity.parameters[:email_id]
    return unless message = emails.find {|_| _.id == email_id }
    html_part = message.content.raw_html
    
    # TODO: investigate implications of rendering html emails ...
    html_part.present? ? html_part.html_safe : message.content.raw_text
  end
  
  def description(activity)
    # TODO: render haml from opened_request(activity) etc.
    case activity.key
      when /request\.open/    ; "opened request"
      when /request\.reply/   ; "replied to X"
      when /request\.assign/  ; "assigned request to #{assignee(activity)}"
      when /request\.label/   ; "labelled request as #{labelled(activity)}"
      when /request\.close/   ; "closed request"
      when /request\.rename/  ; "renamed request as #{renamed(activity)}"
      when /request\.merge/   ; "merged request #{merged(activity)}"
    else
      activity.key
    end
  end
  
  def time_day(activity)
    activity.created_at.strftime "%H:%M %a"
  end
  
  def month_year(activity)
    activity.created_at.strftime "%b %d %Y"
  end
  
  def assignee(activity)
    agent = Agent.find activity.parameters[:agent_id]
    link_to agent.name, agent_path(agent)
  end
  
  def labelled(activity)
    labels = activity.parameters[:labels].split(/(,|\s)/).flatten
    labels.map do |label|
      capture_haml { haml_tag 'button.btn.btn-primary.btn-xs', label }
    end.join ' '
  end
  
  def renamed(activity)
    capture_haml { haml_tag 'i', activity.parameters[:name] }
  end
  
  def merged(activity)
    capture_haml do 
      haml_tag 'i', "##{activity.parameters[:request_id]}"
      haml_tag 'strong', activity.parameters[:request_name]
    end
  end
end
