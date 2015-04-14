module ActivitiesHelper
  # TODO: delegate methods to ActivityView
  # ActivityView.new activity
  # activity.message_content(messages)
  # activity.description
  
  def message_content(activity, messages)
    return unless messages
    return unless message_id = activity.parameters[:message_id]
    messages.find {|_| _.id == message_id }.content.body
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