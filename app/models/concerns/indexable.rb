module Indexable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    after_commit on: [:create]  { update_index :index  }
    after_commit on: [:update]  { update_index :update }
    before_destroy              { update_index :delete }
  end

  def update_index(name)
    IndexJob.perform_later self, name.to_s
  end
end