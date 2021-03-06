class ImagesController < ApplicationController
  def create
    # Successfull image storge required for redactor response? If not ...
    # FIXME: serialize file & enqueue job
    @image =  ImageJob.perform_now current_team, params[:file]
    
    respond_to do |format|
      format.html do
        render text:{filelink:@image.image}.to_json
      end
    end
  end

  def index
    @assets = Asset::Image.where team:current_team
      
    respond_to do |format|
      format.json { render json:@assets }
    end
  end
end
