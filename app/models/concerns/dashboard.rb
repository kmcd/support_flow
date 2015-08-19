class Dashboard
  attr_reader :team, :page

  def initialize(team, page=1)
    @team, @page = team, page
  end

  def open_requests
    team.requests.where(open:true).size
  end

  def closed_requests
    team.requests.where(open:false).size
  end

  def first_reply
    Statistic::Reply.owned_by(team).time
  end

  def average_close
    Statistic::Close.owned_by(team).time
  end

  def customer_happiness
    Statistic::Happiness.owned_by(team).time
  end

  def activities
    Activity.where(team:team).
      order(created_at: :desc).
      page page
  end

  def timeline
    @timeline ||= activities.
      group_by {|_| _.created_at.to_date }.
      sort_by(&:first).
      reverse
  end
end
