class Merge
  attr_reader :original, :duplicate
  
  def initialize(original,duplicate)
    @original, @duplicate = original, duplicate
  end
  
  def save
    duplicate.messages.update_all request_id:@original.id
    duplicate.activities.update_all trackable_id:@original.id
    duplicate.destroy!
  end
end