require 'elasticsearch/model'

class IndexJob < ActiveJob::Base
  attr_reader :record
  queue_as :default

  def perform(record, operation)
    @record = record
    method(operation).call
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
  end
end

Request.class_eval do
  def as_indexed_json(options={})
    self.as_json(
      {
        only: %i[
          id
          team_id
          agent_id
          customer_id
          open
          emails_count
          created_at
          updated_at
        ],
        methods:  %i[ name labels ],
        include: {
          agent:    { methdods: %i[ name ], only: %i[] },
          customer: { methods:  %i[ name company ], only: %i[] },
          emails:   { methods:  %i[ text ], only: %i[] }
        }
      }.merge!(options)
    )
  end
end

# TODO: dry up index fields with CustomerSearch
Customer.class_eval do
  def as_indexed_json(options={})
    self.as_json(
      {
        only: %i[ id team_id ],
        methods: %i[
          id
          team_id
          name
          labels
          company
          phone
          email_address
          open_count
          close_count
          created_at
          updated_at
        ]
      }.merge!(options)
    )
  end
end
