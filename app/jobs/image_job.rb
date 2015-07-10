class ImageJob < ActiveJob::Base
  include Uploadable

  def perform(team, file)
    super
    create_thumbnail
    update_image_manifest
  end
  
  private
  
  def save_asset
    image = MiniMagick::Image.open file.path
    image.auto_orient
    image.write asset_path
  end
  
  def create_thumbnail
    image = MiniMagick::Image.open file.path
    image.resize '150x200' # FIXME: image manager distorted at 100x75
    image.auto_orient
    image.write thumbnail_path
  end
  
  def update_image_manifest
    filename = file.original_filename
    
    Asset::Image.create! team:team,
      thumb:relative(thumbnail_path),
      image:relative(asset_path),
      title:File.basename(filename, File.extname(filename))
  end
  
  def thumbnail_path
    extention = File.extname(asset_path)
    asset_path.to_s.gsub /#{Regexp.quote(extention)}/, "-thumb#{extention}"
  end
  
  def relative(path)
    File.join '/files', File.basename(path)
  end
end
