class GuideObserver < ActiveRecord::Observer
  def after_create(guide)
    guide.create_activity :create
  end
  
  def after_update(guide)
    guide.create_activity :update
  end
  
  def before_save(guide)
    guide.generate_slug
  end
end

Guide.class_eval do
  def generate_slug
    self.slug = name.parameterize
  end
  
  def create_activity(key)
    Activity.create \
      key:"guide.#{key.to_s}",
      trackable:self,
      owner:current_agent,
      team:team
  end
end
