class GuidesController < ApplicationController
  before_action :set_guide, only: [:update, :show, :edit]
  delegate :team, to: :current_agent
  
  def index
    @guides = team.guides
  end
  
  def new
    @guide = team.guides.new
  end
  
  def create
    if guide = team.guides.create(guide_params)
    end
  end
  
  def show
    render 'edit' # TODO: change to customer preview view
  end
  
  def update
    @guide.update guide_params
  end
  
  private
  
  def set_guide
    @guide = Guide.find params[:id] # TODO: change to find by slug
  end

  def guide_params
    params.require(:guide).permit %i[ name content ]
  end
end
