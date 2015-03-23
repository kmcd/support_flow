class RequestsController < ApplicationController
  before_action :set_request, only: [:update, :show]

  # GET /requests
  def index
    @requests = Request.all
  end

  # GET /requests/1
  def show
  end

  # PATCH/PUT /requests/1
  def update
    # TODO: add error handling
    
    respond_to do |format|
      if @request.update request_params
        format.html do
          redirect_to @request, notice: 'Request successfully updated.'
        end
        
        format.js {}
      end
    end
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.first # Request.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def request_params
    params.require(:request).permit :agent_id
  end
end
