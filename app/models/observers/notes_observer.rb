class NotesObserver < ActiveRecord::Observer
  observe :request
  
  def after_update(request)
    request.notes_activity
  end
end

Request.class_eval do
  def notes_activity
    return unless notes_changed?
    return if notes_change == [nil, '']

    create_activity :notes
  end
end
