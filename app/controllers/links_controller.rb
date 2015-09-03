class LinksController < ApplicationController
  def index
    respond_to do |format|
      format.json { render json:guide_links }
    end
  end

  private

  def guide_links
    links = [ { "name": "Select guide", "url": false } ]
    links << GuideLinks.new(current_team).link_json
    links.flatten
  end

end

class GuideLinks < Struct.new(:team)
  include GuidesHelper
  include Rails.application.routes.url_helpers
  Rails.application.routes.default_url_options = \
    ActionMailer::Base.default_url_options

  def link_json
    Guide.pages(team).map do |guide|
      link_json_for guide
    end
  end

  private

  def link_json_for(guide)
    link_text, page_url = if guide.home_page?
      [ 'Home page', team_public_guides_url(team, host:host) ]
    else
      [ guide.name.titleize, team_public_guide_url(team, guide.name.parameterize, host:host) ]
    end

    { name:link_text, url:page_url }
  end
end
