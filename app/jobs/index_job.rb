require 'elasticsearch/model'

class IndexJob < ActiveJob::Base
  attr_reader :record
  queue_as :default

  def perform(record, operation)
    @record = record
    method(operation.to_sym).call
  end

  private

  # FIXME: update agent, customer, email associations ...
  def index
    record.__elasticsearch__.index_document
  end

  def update
    record.__elasticsearch__.update_document
  end

  def delete
    record.__elasticsearch__.delete_document

    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      # TODO: log error
  end
end

Request.class_eval do
  include Elasticsearch::Model

  def as_indexed_json(options={})
    self.as_json(
      {
        only: %i[
          id
          team_id
          agent_id
          customer_id
          name
          open
          labels
          emails_count
          created_at
          updated_at
        ],
        include: {
          agent:    { only: %i[ name ] },
          customer: { only: %i[ name company labels ] },
          emails:   { methods:  %i[ text ], only: %i[] },
        }
      }.merge!(options)
    )
  end
end

# TODO: dry up index fields with CustomerSearch
Customer.class_eval do
  include Elasticsearch::Model

  def as_indexed_json(options={})
    self.as_json(
      {
        only: %i[ id team_id ],
        methods: %i[
          id
          team_id
          name
          email_address
          labels
          phone
          company
          open_count
          close_count
          created_at
          updated_at
        ]
      }.merge!(options)
    )
  end

  def open_count
    requests_open_count
  end

  def close_count
    requests_closed_count
  end
end

Guide.class_eval do
  include Elasticsearch::Model

  def as_indexed_json(options={})
    return {}.to_json if template?

    self.as_json(
      {
        methods: %i[
          name
          text_content
        ]
      }.merge!(options)
    )
  end
end
