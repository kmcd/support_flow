class TeamsController < ApplicationController
  helper_method :dashboard
  
  def show
  end
  
  def dashboard
    @dashboard ||= Dashboard.new current_team
  end
end
