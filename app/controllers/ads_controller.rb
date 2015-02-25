class AdsController < ApplicationController
  def index
  end
  
  def show
    render action:params[:ad]
    
    rescue ActionView::MissingTemplate
      render file:'public/404'
  end
end
