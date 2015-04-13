class Asset < ActiveRecord::Base
  belongs_to :team

  def asset_path(asset)
    "/assets/#{asset}"
  end
  
  class Image < self
    def as_json(options={})
      { thumb:asset_path(thumb),
        image:asset_path(image),
        title:asset_path(title) }
    end
  end
  
  class File < self
    def as_json(options={})
      { title:title,
        link:"/assets/#{link}",
        name:title,
        size:size}
    end
  end
end
