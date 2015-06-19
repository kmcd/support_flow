class RequestsController < ApplicationController
  before_action :set_request, only: %i[ update show ]
  helper_method :search_query

  def index
    @requests = RequestSearch.
      new(search_query, current_team, params[:page]).requests
  end

  def show
    @activities = @request.activities.order :created_at
    email_ids = @activities.map {|_| _.parameters[:email_id] }.compact
    @emails = [] #Message.where(id:email_ids)
  end

  def update
    # TODO: add error handling
    if @request.update request_params
      Activity.create @request, @agent
      @activity = @request.activities.order(:created_at).last
    end
  end
  
  private
  
  def set_request
    # TODO: app layout 404 instead of exception
    @request = current_team.requests.where(number:params[:id]).first
  end

  def request_params
    params.require(:request).permit %i[ agent_id label name open ]
  end
  
  def search_query
    # TODO: remove sort:new from default search box
    params[:q].present? ? params[:q] : 'sort:new'
  end
end
