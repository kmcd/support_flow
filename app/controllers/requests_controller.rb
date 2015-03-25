class RequestsController < ApplicationController
  before_action :set_request, only: [:update, :show]

  # GET /requests
  def index
    @requests = Request.all
  end

  # GET /requests/1
  def show
    @activities = @request.activities.order :created_at
    message_ids = @activities.map {|_| _.parameters[:message_id] }.compact
    @messages = Message.where(id:message_ids)
  end

  # PATCH/PUT /requests/1
  def update
    # TODO: add error handling
    if @request.update request_params
      @activity = Activity.create @request, @agent
    end
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.first # Request.find(params[:id])
    @agent = Agent.first # current_user
  end

  # Only allow a trusted parameter "white list" through.
  def request_params
    params.require(:request).permit :agent_id, :label
  end
end
