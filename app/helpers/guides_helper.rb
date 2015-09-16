module GuidesHelper
  # TODO: move to app/controllers/concerns/guide_view.rb
  # @guide.extend GuideViewable

  def summary(guide)
    truncate Nokogiri::HTML(guide.content).text, length:100
  end

  def link_to_public(guide)
    name = guide.home_page? ? '' : guide.name.parameterize
    url = team_public_guide_url current_team, name, host:host, protocol:'http'
    link_to url, url
  end

  def search_url
    team_guide_search_url current_team, host:host
  end

  def readonly?(guide)
    return if guide.new_record?

    !guide.deleteable?
  end

  def guide_name(guide)
    guide.home_page? ? 'Home' : guide.name.titleize
  end

  def edit_guide_link(guide)
    name =  guide.home_page? ? 'Home Page' : guide.name.titleize
    link_to name, edit_guide_path(guide)
  end

  def guide_link(team, guide)
    team_public_guide_url team.name.parameterize, guide.name.parameterize
  end

  def guide_saved?
    flash.notice == 'saved'
  end

  def host
    case Rails.env
      when /development/  ; 'dev.getsupportflow.com'
      when /test/         ; 'test.getsupportflow.com'
      when /production/   ; 'getsupportflow.com'
    end
  end
  
  def help_url(guide)
    if guide.template?
      team_public_guide_url('help', 'guides', anchor:'template', host:host)
    elsif guide.home_page?
      team_public_guide_url('help', 'guides', anchor:'home', host:host)
    else
      team_public_guide_url('help', 'guides', anchor:'edit', host:host)
    end
  end
end
