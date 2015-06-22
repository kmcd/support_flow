class RequestsController < ApplicationController
  before_action :set_request, only: %i[ show edit update ]
  helper_method :search_query

  def index
    @requests = RequestSearch.
      new(search_query, current_team, params[:page]).requests
  end

  def show
  end

  def edit
  end

  def update
    if @request.update request_params
      redirect_to team_request_path(current_team, @request)
    else
      flash[:errors] = ''
      render :edit
    end
  end

  private

  def set_request
    # TODO: app layout 404 instead of exception
    @request = current_team.requests.where(number:params[:id]).first
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
