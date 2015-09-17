class PublicGuidesController < ApplicationController
  skip_before_action :authenticate_agent
  skip_before_action :authorise_agent
  
  layout false

  def index
    @guide = PublicGuide.new params[:team_name], :index
    @guide.increment_view_count current_agent
    render :show
  end

  def show
    @guide = PublicGuide.new params[:team_name], params[:slug]

    if @guide.present?
      @guide.increment_view_count current_agent
    else
      render file:"#{Rails.root}/public/404", status: :not_found
    end
  end

  private

  def current_agent
    request_referred_from_app?
  end

  def request_referred_from_app?
    return unless request.referer

    request.referer[/getsupportflow\.net/]
  end
  
  def ssl_configured?
    false
  end
end
