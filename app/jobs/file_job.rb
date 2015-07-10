class FileJob < ActiveJob::Base
  include ActionView::Helpers::NumberHelper
  include Uploadable
  attr_reader :name

  def perform(team, file)
    super
    update_file_manifest
  end
  
  private
  
  def update_file_manifest
    filename = file.original_filename
    
    Asset::File.create! team:team,
      link:File.join('/files', File.basename(asset_path)),
      title:File.basename(filename, File.extname(filename)),
      size:number_to_human_size(file.size)
  end
end
