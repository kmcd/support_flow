class RequestsController < ApplicationController
  before_action :set_request, only: %i[ update show ]

  def index
    @requests = AgentSearch.new(params[:q]).results
  end

  def show
    @activities = @request.activities.order :created_at
    message_ids = @activities.map {|_| _.parameters[:message_id] }.compact
    @messages = Message.where(id:message_ids)
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
    @request = current_team.requests.find params[:id]
  end

  def request_params
    params.require(:request).permit %i[ agent_id label name open ]
  end
end
