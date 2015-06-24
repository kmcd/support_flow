class MergesController < ApplicationController
  before_action :set_request, only: %i[ new create destroy ]
  helper_method :customer_requests

  # GET /merge/1
  def new
    cookies[ "merge_request_#{@request.id}"] = true
  end

  # POST /merge/1
  def create
    @merged_request = Request.find params[:merge_request_id]
    Merge.new(@merged_request, @request).save
    Activity.new(request:@merged_request, owner:@agent).merge @request

    cookies[ "merge_request_#{@request.id}"] = false
    redirect_to team_request_path(current_team, @merged_request)
  end

  def destroy
    cookies[ "merge_request_#{@request.id}"] = false
    redirect_to team_request_path(current_team, @request)
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

  def customer_requests
    return [] if @request.blank?
    @request.customer.requests.where.not id:@request.id
  end
end
