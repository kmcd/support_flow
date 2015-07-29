class GuideSearchController < ApplicationController
  layout false

  def show
    @team = Team.where(name:params[:team_name]).first
    @guides = GuideSearch.new(search_query, @team, params[:page]).guides
  end
end
