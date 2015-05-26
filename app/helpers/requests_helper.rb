module RequestsHelper
  # TODO: move buttons to partials
  def dropdown_button(name, button_type="default")
    haml_tag '.btn-group' do
      haml_tag("button.btn.btn-#{button_type}.btn-sm.dropdown-toggle", 
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
  
  def team_labels
    @team_labels ||= Request.all_labels
  end
  
  def label_button
    render('label') && return if team_labels.empty?
    
    new_request_labels =  team_labels - @request.labels
      
    dropdown_button 'Label', 'link' do
      new_request_labels.each do |label|
        haml_tag :li do
          form = capture do
            form_for(@request, class:'hide', remote:true,
              authenticity_token:true) do |form|
              concat form.hidden_field(:label, value:label)
            end
          end
          haml_concat form
          
          haml_concat link_to(label, '#', 'data-form' => "#edit_request_#{@request.id}")
        end
      end
      
      haml_tag 'li.divider'
      haml_tag :li do
        haml_concat link_to 'Add a new Label', '#'
      end
    end
  end
  
  # TODO: find a home for mailto links
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
  
  def link_for(owner)
    return unless owner
    link = owner.is_a?(Agent) ? agent_path(owner) : customer_path(owner)
    link_to owner.name, link
  end
  
  # TODO: move to RequestView
  def show_merge?(request)
    cookies["merge_request_#{request.id}"] == 'true'
  end
  
  def name_for(request)
    request.name || request.emails.first.content.subject
  end
  
  def labels_for(request)
    request.labels.map do |label|
      link_to label, requests_path(q:"label:#{label}")
    end.join(" &bull; ").html_safe
  end
  
  def placeholder
    'Search Requests ...' unless params[:q].present?
  end
  
  def query
    params[:q] || ""
  end
  
  def facet(status)
    query_string = query.clone
    status_facet = "is:#{status.to_s}"
    return query_string if query_string.gsub!(/is:\w+/, status_facet)
    [ query_string, status_facet ].map(&:strip).join ' '
  end
  
  def agent_facet(agent)
    query_string = query.clone
    agent = "agent:#{agent.id}"
    return query_string if query_string.gsub!(/agent:\d+/, agent)
    [ query_string, agent ].map(&:strip).join ' '
  end
  
  def customer_facet(customer)
    query_string = query.clone
    customer = "customer:#{customer.id}"
    return query_string if query_string.gsub!(/customer:\d+/, customer)
    [ query_string, customer ].map(&:strip).join ' '
  end
  
  def label_facet(label)
    query_string = query.clone
    return query_string if query_string =~ /label:#{label}/
    [ query_string, "label:#{label}" ].map(&:strip).join ' '
  end
  
  def sort_facet(order)
    query_string = query.clone
    return query_string if query_string.gsub!(/sort:\w+/, "sort:#{order}")
    [ query_string, "sort:#{order}" ].map(&:strip).join ' '
  end
end
