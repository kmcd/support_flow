module Indexable
  extend ActiveSupport::Concern
  
  included do
    after_commit :update_search_index
  end
  
  private
  
  def update_search_index
    UpdateSearchIndexJob.perform_later self, self.changes.to_json
  end
end
