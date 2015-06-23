class GuidesController < ApplicationController
  skip_before_filter :require_login, only:%i[ public ]
  before_action :set_guide, only: %i[ update show edit destroy ]

  def index
    @guides = Guide.pages current_team
  end

  def new
    @guide = Guide.new
  end

  def create
    @guide = current_team.guides.new guide_params

    if @guide.save
      redirect_to guide_path(@guide)
    else
      render :new
    end
  end

  def show
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
    redirect_to guides_path
  end

  def public
    public_guide = PublicGuide.new params[:team], params[:guide]

    if public_guide.present?
      public_guide.increment_view_count current_agent
      render text:public_guide.html
    else
      render file:"#{Rails.root}/public/404", layout:false, status: :not_found
    end
  end

  private

  def set_guide
    @guide = Guide.find params[:id]
  end

  def guide_params
    params.require(:guide).permit %i[
      name
      content
    ]
  end
end
