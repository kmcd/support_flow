require 'test_helper'

class TimelineTest < ActionDispatch::IntegrationTest
end

class TeamTimelineTest < TimelineTest
  # guide.create
  # guide.delete
  # guide.update
  # request.assign
  # request.close
  # request.comment
  # request.customer
  # request.first_reply
  # request.happiness
  # request.label
  # request.label.remove
  # request.merge
  # request.notes
  # request.open
  # request.rename
  # request.reopen
  # request.reply
  # request.reply_time
end

class RequestTimelineTest < TimelineTest
end

class AgentTimelineTest < TimelineTest
end

class CustomerTimelineTest < TimelineTest
end
