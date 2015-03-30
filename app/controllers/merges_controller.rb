class MergesController < ApplicationController
  before_action :set_request, only: [:new, :create]

  # GET /merge/1
  def new
    @customer_requests = @request.customer.requests.where.not id:@request.id
  end

  # POST /merge/1
  def create
    @merged_request = Request.find params[:merge_request_id]
    Merge.new(@merged_request, @request).save
    
    redirect_to request_path(@merged_request)
  end
  
  private
  
  # Use callbacks to share common setup or constraints between actions.
  def set_request
    @request = Request.find params[:request_id]
    @agent = Agent.first # current_user
  end

  # Only allow a trusted parameter "white list" through.
  def request_params
    params.require(:merge).permit %i[ request_id ]
  end
end
