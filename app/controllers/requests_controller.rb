class RequestsController < ApplicationController
  include Attachable
  helper :all
  before_action :set_request, only: %i[ show edit update ]
  helper_method :search_query

  def new
    @request = Request.new
  end

  def create
    @request = current_team.requests.new request_params

    if @request.save
      redirect_to team_request_path(current_team, @request.number)
    else
      render :new
    end
  end

  def index
    @requests = RequestSearch.
      new(search_query, current_team, params[:page]).
      requests.
      paginate page:params[:page]
  end

  def show
  end

  def edit
  end

  def update
    if @request.update request_params
      redirect_to team_request_path(current_team, @request.number)
    else
      render :edit
    end
  end

  private

  def set_request
    # TODO: app layout 404 instead of exception
    @request = current_team.requests.where(number:params[:number]).first
    @request.current_agent = current_agent
  end

  def request_params
    params.require(:request).permit %i[
      name
      label_list
      open
      customer_id
      agent_id
      happiness
      notes
    ]
  end
end
