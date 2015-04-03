require 'elasticsearch/persistence/model'

class UpdateSearchIndexJob < ActiveJob::Base
  attr_reader :model, :attribute_changes
  queue_as :default

  def perform(model, attribute_changes={})
    @model, @attribute_changes = model, JSON.parse(attribute_changes)
    update_request_index
    update_message_index
  end
  
  private
  
  def update_request_index
    return unless request
    
    if request_document.persisted?
      request_document.update_attributes changes
    else
      RequestDocument.create model.attributes
    end
  end
  
  def update_message_index
    return unless message && message.request_id
    
    request_document = RequestDocument.find message.request_id
    
    # FIXME: always create Griddler::Email value object from text
    email = if message.content.instance_of?(Griddler::Email)
      [ message.content.subject, message.content.raw_text ].join ' '
    else
      message.content
    end
    
    request_document.messages << email
    request_document.save
  end
  
  def request_document
    @request_document ||= RequestDocument.find model.id
    rescue Elasticsearch::Persistence::Repository::DocumentNotFound
      RequestDocument.new
  end
  
  def changes
    attribute_changes.each_with_object({}) do |previous,changes|
      changes[previous.first.to_sym] = previous.flatten.last
    end
  end
  
  def message
    model if model.instance_of? Message
  end
  
  def request
    model if model.instance_of? Request
  end
end
