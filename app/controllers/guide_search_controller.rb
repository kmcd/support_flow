class GuideSearchController < ApplicationController
  skip_before_action :authenticate_agent
  skip_before_action :authorise_agent

  layout false

  def show
    @team = Team.where(name:params[:team_name]).first
    @guides = GuideSearch.new(search_query, @team, params[:page]).guides
  end
  
  def ssl_configured?
    false
  end
end
