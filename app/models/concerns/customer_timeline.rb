module CustomerTimeline
  extend ActiveSupport::Concern

  included do
  end

  private
  
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
