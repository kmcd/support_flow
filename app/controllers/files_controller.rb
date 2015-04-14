class FilesController < ApplicationController
  def create
    @file = UploadFileJob.perform_now current_team, params[:file]
    
    respond_to do |format|
      format.html do
        render text:{filelink:@file.link}.to_json
      end
    end
  end

  def index
    @assets = Asset::File.where team:current_team
    
    respond_to do |format|
      format.json { render json:@assets }
    end
  end
end
