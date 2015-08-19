class IndexObserver < ActiveRecord::Observer
  observe :customer, :guide, :request
  
  # TODO: investigate whether callback should be after_commit_on_create
  def after_create(model)
    update_search_index model, :index
  end
  
  def after_update(model)
    update_search_index model, :update
  end
  
  def before_destroy(model)
    update_search_index model, :delete
  end
  
  private
  
  def update_search_index(model, index_name)
    IndexJob.perform_later model, index_name.to_s
  end
end
