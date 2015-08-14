class GuidesController < ApplicationController
  before_action :set_guide, only: %i[ update edit destroy ]
  skip_before_filter :authenticate_agent
  skip_before_filter :authorise_agent

  def index
    @guides = Guide.pages current_team
  end

  def new
    @guide = Guide.new
  end

  def create
    @guide = current_team.guides.new guide_params

    if @guide.save
      redirect_to team_guides_path(current_team)
    else
      render :new
    end
  end

  def update
    if @guide.update guide_params
      flash.notice = 'saved'
      redirect_to edit_guide_path(@guide)
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
    params.
      require(:guide).
      permit(%i[ name content ]).
      merge( { current_agent:current_agent } )
  end
end
