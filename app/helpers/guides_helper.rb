module GuidesHelper
  def link_to_guide_url(current_team, guide)
    return unless current_team.name
    
    guide_url = if guide.name == 'index'
      public_guide_url current_team.name
    else
      public_guide_url current_team.name, guide.name
    end
    
    link_to guide_url, guide_url
  end
  
  def summary(guide)
    truncate Nokogiri::HTML(guide.content).text, length:100
  end
end
