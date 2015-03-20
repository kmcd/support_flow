module RequestsHelper
  def open_since
    [ rand(10).to_s + 'd',
      rand(1..24).to_s  + 'h',
      rand(1..60).to_s  + 'm' ].join ' '
  end
  
  def default_button(label)
    haml_tag(:button, class:'btn btn-default') { haml_concat label }
  end
  
  def avatar(owner)
    owner && owner.avatar
  end
  
  # TODO: render (_open, _reply, ... ) partials instead
  def description(activity)
    case activity.key
    when /request\.open/    ; "opened request"
    when /request\.reply/   ; "replied to X"
    when /request\.assign/  ; "assigned request to #{assignee(activity)}"
    when /request\.tag/     ; "tagged request as #{tagged(activity)}"
    when /request\.close/   ; "closed request"
    else
      activity.key
    end
  end
  
  def timestamp(activity)
    activity.created_at.to_s(:long)
  end
  
  def link_for(owner)
    return unless owner
    link = owner.is_a?(Agent) ? agent_path(owner) : customer_path(owner)
    link_to owner.name, link
  end
  
  def assignee(activity)
    agent = Agent.find activity.parameters[:agent_id]
    link_to agent.name, agent_path(agent)
  end
  
  def tagged(activity)
    # FIXME: render tags & colored buttons
    activity.parameters[:tags].split(/(,|\s)/).flatten.join ','
  end
end
