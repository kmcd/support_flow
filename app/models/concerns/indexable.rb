module Indexable
  extend ActiveSupport::Concern
  
  included do
    include Elasticsearch::Model
    after_commit on: [:create]  { IndexJob.perform_later self, 'index' }
    after_commit on: [:update]  { IndexJob.perform_later self, 'update' }
    after_commit on: [:destroy] { IndexJob.perform_later self, 'delete' }
  end
end