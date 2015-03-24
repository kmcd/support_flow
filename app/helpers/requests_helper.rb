module RequestsHelper
  def open_since
    [ rand(10).to_s + 'd',
      rand(1..24).to_s  + 'h',
      rand(1..60).to_s  + 'm' ].join ' '
  end
  
  def message_content(activity, messages)
    return unless message_id = activity.parameters[:message_id]
    messages.find {|_| _.id == message_id }.content.body
  end
  
  def default_button(label)
    haml_tag('button.btn.btn-default.btn-sm.') { haml_concat label }
  end
  
  def dropdown_button(name)
    haml_tag '.btn-group' do
      haml_tag('button.btn.btn-default.btn-sm.dropdown-toggle', 
        'data-toggle' => 'dropdown') do
        haml_concat name
        haml_tag 'span.caret'
      end
      
      haml_tag 'ul.dropdown-menu' do
        yield
      end
    end
  end
  
  def assign_button
    dropdown_button 'Assign' do
      Team.first.agents.order(:email_address).each do |agent|
        haml_tag('li') do
          form = capture do
            form_for(@request, class:'form-inline', remote:true, authenticity_token:true) do |form|
              concat form.hidden_field(:agent_id, value:agent.id)
              concat form.submit agent.email_address, class:'btn btn-link'
            end
          end
          haml_concat form
        end
      end
    end
  end
  
  def reply_button
    dropdown_button 'Reply' do
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
  
  def label_button
    dropdown_button 'Label' do
      Request.all_labels.each do |label|
        haml_tag :li do
          haml_concat link_to label, '#'
        end
      end
      
      haml_tag 'li.divider'
      haml_tag :li do
        haml_concat link_to 'Add new label', '#'
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
  
  def description(activity)
    # TODO: render haml from opened_request(activity) etc.
    case activity.key
      when /request\.open/    ; "opened request"
      when /request\.reply/   ; "replied to X"
      when /request\.assign/  ; "assigned request to #{assignee(activity)}"
      when /request\.label/   ; "labelled request as #{labelled(activity)}"
      when /request\.close/   ; "closed request"
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
  
  def link_for(owner)
    return unless owner
    link = owner.is_a?(Agent) ? agent_path(owner) : customer_path(owner)
    link_to owner.name, link
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
end
