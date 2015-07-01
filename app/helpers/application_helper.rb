module ApplicationHelper
  def duration(seconds)
    seconds = seconds.to_i + rand(60*rand(5))
    _, sec = seconds.divmod 60
    _, mins = _.divmod 60
    days, hours = _.divmod 60
    [ hours, mins ]
  end
  
  private
  
  def append_facet(name)
    query = case name
      when /open/     ; search_query.gsub /open:\w+/, ''
      when /sort/     ; search_query.gsub /sort:\w+/, ''
      when /agent_id/ ; search_query.gsub /agent_id:\w+/, ''
      when /labels/   ; search_query.gsub /#{name}/, ''
    end
    
    [ query, name ].join(' ').gsub /\s+/, ' '
  end
end
