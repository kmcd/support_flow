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
    @first_reply ||= Statistic::Reply.
      where(owner:team).
      first_or_initialize.
      value.to_i / 60
  end

  def average_close
    @average_close ||= Statistic::Close.
      where(owner:team).
      first_or_initialize.
      value.to_i / 60
  end

  def customer_happiness
    @customer_happiness ||= Statistic::Happiness.
      where(owner:team).
      first_or_initialize.
      value.to_i
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
