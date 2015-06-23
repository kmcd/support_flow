class LinksController < ApplicationController
  def index
    respond_to do |format|
      format.json { render json:guide_links }
    end
  end
  
  private
  
  def guide_links
    links = [ { "name": "Select guide", "url": false } ]
    links << link_json('home page')
    links << Guide.pages(current_team).map {|_| link_json _.name, _ }
    links.flatten
  end
  
  def link_json(name, guide=nil)
    page = guide.present? ? guide.name : nil
    { name:name, url:guide_url(current_team, page)  }
  end
end
