class TeamsController < ApplicationController
  helper_method :dashboard
  
  def show
  end
  
  def dashboard
    @dashboard ||= Dashboard.new current_team
  end
end

class Dashboard
  attr_reader :team
  
  def initialize(team)
    @team = team
  end
  
  def open_requests
    team.requests.where(open:true).size
  end
  
  def first_reply
    @first_reply ||= Statistic::Reply.where(owner:team).first.value.to_i / 60
  end
  
  def average_close
    @average_close ||= Statistic::Close.
      where(owner:team).first.value.to_i / 60
  end
  
  def customer_happiness
    @customer_happiness ||= Statistic::Happiness.
      where(owner:team).first.value.to_i
  end
end
