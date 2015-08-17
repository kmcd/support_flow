module Timeline
  def timeline
    Stream.new self
  end
  
  private
  
  class Stream
    def initialize(objekt)
      @objekt = objekt
    end
  
    def activities
      Activity.where(
        "team_id = ? AND (
          ( owner_type = '#{type}' AND owner_id = ? ) OR
          ( trackable_type = '#{type}' AND trackable_id = ? ) OR
          ( recipient_type = '#{type}' AND recipient_id = ? ))",
        team_id, id, id, id).
        order(created_at:'desc').
        group_by {|_| _.created_at.to_date }.
        sort_by(&:first).
        reverse
    end
  
    def empty?
      activities.empty?
    end
  
    private
  
    def type
      @objekt.class.name
    end
  
    def team_id
      @objekt.team_id
    end
  
    def id
      @objekt.id
    end
  end
end
