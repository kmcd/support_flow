module Indexable
  extend ActiveSupport::Concern
  
  included do
    include Elasticsearch::Model
    after_commit on: [:create]  { IndexJob.perform self, :index }
    after_commit on: [:update]  { IndexJob.perform self, :update }
    after_commit on: [:destroy] { IndexJob.perform self, :delete }
  end
end