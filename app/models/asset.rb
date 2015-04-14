class Asset < ActiveRecord::Base
  belongs_to :team

  class Image < self
    def as_json(options={})
      { thumb:thumb, image:image, title:title }
    end
  end
  
  class File < self
    def as_json(options={})
      { title:title, link:link, name:title, size:size }
    end
  end
end
