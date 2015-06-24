module GuidesHelper
  def summary(guide)
    truncate Nokogiri::HTML(guide.content).text, length:100
  end
  
  def guide_link(guide)
    name =  guide.home_page? ? 'Home Page' : guide.name.titleize
    link_to name, edit_guide_path(guide)
  end
  
  def link_to_public(guide)
    host = case Rails.env
      when /development/  ; 'dev.getsupportflow.com'
      when /test/         ; 'test.getsupportflow.com'
      when /production/   ; 'getsupportflow.com'
    end
    
    name = guide.home_page? ? '' : guide.name.parameterize
    
    url = public_guide_url current_team, name, host:host
    link_to url, url
  end
  
  def readonly?(guide)
    return if guide.new_record?
    !guide.deleteable?
  end
end
