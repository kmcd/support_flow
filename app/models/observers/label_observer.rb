class LabelObserver < ActiveRecord::Observer
  observe :request

  def after_update(request)
    request.add_label_activity
    request.remove_label_activity
  end
end

Request.class_eval do
  def add_label_activity
    return unless labels_changed?
    return if new_labels.empty?

    create_activity :label,
      parameters:{ label:new_labels.join(' ') }
  end

  def remove_label_activity
    return unless labels_changed?
    return if removed_labels.empty?

    create_activity 'label.remove',
      parameters:{ label:removed_labels }
  end

  private

  def new_labels
    labels_change.last - labels_change.first
  end

  def removed_labels
    labels_change.first - labels_change.last
  end
end
