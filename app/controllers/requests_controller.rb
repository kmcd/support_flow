class RequestsController < ApplicationController
  before_action :set_request, only: [:update]

  # GET /requests
  def index
    @requests = Request.all
  end

  # GET /requests/1
  def show
  end

  # PATCH/PUT /requests/1
  def update
    if @request.update(request_params)
      redirect_to @request, notice: 'Request was successfully updated.'
    else
      # FIXME: respond to error in-page
      render :edit
    end
  end

  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def request_params
    params[:request]
  end
end
