module Timelineable
  extend ActiveSupport::Concern

  included do
    after_create :set_number

    after_create :enquiry_open
    after_update :customer_reply
    after_update :first_reply_time

    after_update :assignment_activity
    after_update :rename_activity
    after_update :add_label_activity
    after_update :remove_label_activity
    after_update :change_customer_activity
    after_update :customer_happiness_activity
    after_update :notes_activity

    after_update :close_activity
    after_commit :save_close_time
    after_update :reopen_activity
  end

  private

  def set_number
    update number:Request.count
  end

  def enquiry_open
  end

  def customer_reply
  end

  def first_reply_time
  end

  def assignment_activity
    return unless agent_id_changed?

    create_activity 'request.assignment', recipient:agent
  end

  def rename_activity
    return unless name_changed?

    create_activity 'request.rename', parameters:{from:name_was, to:name}
  end

  def remove_label_activity
    return unless labels_changed?

    removed_labels = labels_change.first - labels_change.last

    if removed_labels.any?
      create_activity 'request.label.remove',
        parameters:{ label:removed_labels }
    end
  end

  def add_label_activity
    return unless labels_changed?

    new_labels = labels_change.last - labels_change.first

    if new_labels.any?
      create_activity 'request.label', parameters:{ label:new_labels }
    end
  end

  def change_customer_activity
    return unless customer_id_changed?
    return unless customer_id_was.present?

    create_activity 'request.customer', recipient:customer,
      parameters:{ previous_customer_id:customer_id_was }
  end

  def customer_happiness_activity
    return unless happiness_changed?

    create_activity 'request.happiness', recipient:customer,
      parameters:{ was:happiness_was, now:happiness }
  end

  def notes_activity
    return unless notes_changed?

    create_activity 'request.notes'
  end

  def close_activity
    return unless closing?

    close_time_in_seconds = (0.minutes.ago - created_at).to_i
    create_activity 'request.close', recipient:customer,
      parameters:{ close_time_in_seconds:close_time_in_seconds }
  end

  def save_close_time
    return unless closing?

    Activity.create key:'request.close_time',
      team_id:team_id,
      trackable:self
      owner:agent,
      recipient:customer,
      parameters:{seconds:(Time.now - created_at.to_time).to_i}
  end

  def closing?
    open_changed? && closed?
  end

  def reopen_activity
    return unless open_changed? && !closed?

    create_activity 'request.reopen'
  end

  def create_activity(key, options={})
    args = {
      key:key,
      team_id:team_id,
      trackable:self,
      owner:current_agent
    }.merge!(options)
    Activity.create args
  end
end
