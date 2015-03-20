module RequestsHelper
  def open_since
    [ rand(10).to_s + 'd',
      rand(1..24).to_s  + 'h',
      rand(1..60).to_s  + 'm' ].join ' '
  end
  
  def description_for(request,message)
    return 'Opened' if request.messages.first == message
    'Replied'
    # Display operation: eg command, merge etc.
  end
  
  def default_button(label)
    haml_tag(:button, class:'btn btn-default') { haml_concat label }
  end
end
