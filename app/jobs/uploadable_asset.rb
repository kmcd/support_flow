require 'securerandom'
require 'fileutils'

module UploadableAsset
  extend ActiveSupport::Concern
  
  included do
    attr_reader :team, :file
    queue_as :default
  end

  def perform(team, file)
    @team, @file = team, file
    save_asset
  end
  
  private
  
  def save_asset
    FileUtils.cp file.path, asset_path
  end
  
  def asset_path
    @asset_path ||= unique_asset_path
  end
  
  def unique_asset_path
    name = [
      SecureRandom.hex(4),
      File.basename(file.original_filename).downcase
    ].join('-').gsub /_/, '-'
    
    # TODO: partition by team id, dry up with Asset
    full_path = Rails.root.join 'disk', 'assets', name
    
    File.exists?(full_path) ? unique_asset_path : full_path
  end
end