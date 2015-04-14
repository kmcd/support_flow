module GuidesHelper
  def link_to_guide_url(current_team, guide)
    guide_url = if guide.name == 'index'
      public_guide_url current_team.subdomain
    else
      public_guide_url current_team.subdomain, guide.name
    end
    
    link_to guide_url, guide_url
  end
end
