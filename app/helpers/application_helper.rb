module ApplicationHelper
  def errors_for(objekt, attribute)
    "has-error" if objekt.errors[attribute].present?
  end

  def append_facet(name)
    query = case name
      when /open/     ; search_query.gsub /open:\w+/, ''
      when /sort/     ; search_query.gsub /sort:\w+/, ''
      when /agent_id/ ; search_query.gsub /agent_id:\w+/, ''
      when /labels/   ; search_query.gsub /#{name}/, ''
    end

    [ query, name ].join(' ').gsub /\s+/, ' '
  end

  def head_title
    team_title = [ 'Support Flow'.html_safe, current_team.name ]
    team_title.push(controller_name) unless dashboard?
    team_title.join ' '
  end
  
  def hours_mins_from(seconds)
    seconds.to_i.divmod(60).first.divmod 60
  end

  private

  def dashboard?
    controller_name =~ /teams/
  end
end
