class GuidesController < ApplicationController
  skip_before_filter :require_login, only:%i[ public ]
  before_action :set_guide, only: %i[ update edit destroy ]
  layout false, only: :show

  def index
    @guides = Guide.pages current_team
  end

  def new
    @guide = Guide.new
  end

  def create
    @guide = current_team.guides.new guide_params

    if @guide.save
      Activity.create trackable:@guide, owner:current_agent,
        key:'guide.create'
      redirect_to team_guides_path(current_team)
    else
      render :new
    end
  end

  def show
    @guide = PublicGuide.new params[:team_name], params[:guide_name]
    
    if @guide.present?
      @guide.increment_view_count current_agent
    else
      render file:"#{Rails.root}/public/404",
        layout:false,
        status: :not_found
    end
  end

  def edit
  end

  def update
    if @guide.update guide_params
      redirect_to team_guides_path(current_team)
    else
      render :edit
    end
  end

  def destroy
    @guide.delete
    redirect_to team_guides_path(current_team)
  end

  private

  def set_guide
    @guide = current_team.guides.find params[:id]
  end

  def guide_params
    params.require(:guide).permit %i[
      name
      content
    ]
  end
end
