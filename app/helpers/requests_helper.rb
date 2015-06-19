module RequestsHelper
  def open_facet
    append_facet 'open:true'
  end
  
  def closed_facet
    append_facet 'open:false'
  end
  
  def new_facet
    append_facet 'sort:new'
  end
  
  def old_facet
    append_facet 'sort:old'
  end

  def updated_facet
    append_facet 'sort:updated'
  end
  
  def active_facet
    append_facet 'sort:active'
  end
  
  def agent_facet(agent)
    append_facet "agent_id:#{agent.id}"
  end
  
  def link_to_search(label)
    label_query = append_facet "labels:#{label}"
    link_to label, team_requests_path(current_team, q:label_query),
      class:'btn btn-xs bg-info'
  end
end
