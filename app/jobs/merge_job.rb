class MergeJob < ActiveJob::Base
  attr_reader :original_request, :duplicate_request
  queue_as :default
  
  def perform(original_request, duplicate_request)
    initialise original_request, duplicate_request
    copy_emails
    copy_activities
    copy_labels
    original_request.save! && duplicate_request.destroy!
  end
  
  private
  
  def initialise(original_request, duplicate_request)
    @original_request = original_request
    @duplicate_request = duplicate_request
  end
  
  def copy_emails
    duplicate_request.emails.update_all request_id:original_request.id
  end
  
  def copy_activities
    duplicate_request.activities.update_all trackable_id:original_request.id
  end
  
  def copy_labels
    original_request.labels += duplicate_request.labels
  end
end
