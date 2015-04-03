require 'elasticsearch/persistence/model'

class RequestDocument
  include Elasticsearch::Persistence::Model
  include Elasticsearch::Model::Callbacks
  
  attribute :team_id, Integer
  attribute :agent_id, Integer
  attribute :customer_id, Integer
  
  attribute :name, String # boost name (at query time?)
  attribute :open, Boolean
  attribute :labels, Array
  
  attribute :created_at, Date
  attribute :updated_at, Date
  
  attribute :messages, Array
  attribute :message_count, Integer
end