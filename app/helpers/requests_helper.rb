module RequestsHelper
  def open_since
    [ rand(10).to_s + 'd',
      rand(1..24).to_s  + 'h',
      rand(1..60).to_s  + 'm' ].join ' '
  end
  
  def default_button(label)
    haml_tag('button.btn.btn-default.btn-sm.') { haml_concat label }
  end
  
  def reply_button
    haml_tag('button.btn.btn-default.btn-sm.dropdown-toggle', 
      'data-toggle' => 'dropdown') do
      haml_concat 'Reply'
      haml_tag 'span.caret'
    end
      
    haml_tag 'ul.dropdown-menu' do
      haml_tag('li.dropdown-header') { haml_concat 'Customer' }
      
      haml_tag('li') do
        customer = @request.customer
        haml_concat \
          mail_to customer.email_address, customer.name,
            :bcc      => "request.#{@request.id}@getsupportflow.net",
            :subject  => "Re: #{@request.name}",
            :body     => reply_template(customer.name)
      end
      
      haml_tag('li.dropdown-header') { haml_concat 'Agents' }
      
      Team.first.agents.each do |agent|
        haml_tag('li') do
          haml_concat \
            mail_to agent.email_address, agent.name,
              :cc       => "request.#{@request.id}@getsupportflow.net",
              :subject  => "Re: #{@request.name} [ Support Flow request##{@request.id} ]",
              :body     => reply_template(agent.name, @request)
        end
      end
      
      haml_tag 'li.divider'
      
      haml_tag('li') do
        haml_concat \
          mail_to '', 'Blank',
            :cc      => "request.#{@request.id}@getsupportflow.net",
            :subject  => "Re: #{@request.name}",
            :body     => reply_template('', @request)
      end
    end
  end
  
  def reply_template(to, request=nil)
    request_url = request && \
      "https://getsupportflow.com/requests/#{request.id}" 
    <<-MESSAGE.strip_heredoc
    Hi #{to},
    
    #{request_url}
    
    Thanks,
    
    Keith
    MESSAGE
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
