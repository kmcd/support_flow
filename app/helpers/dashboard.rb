class Dashboard
  attr_reader :team

  def initialize(team)
    @team = team
  end

  def open_requests
    team.requests.where(open:true).size
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

  def timeline
    @timeline ||= Activity.
      where(team:team).
      group_by {|_| _.created_at.to_date }.
      sort &:first
  end
end