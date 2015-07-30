module Timelineable
  def timeline
    Timeline.new self
  end
end
