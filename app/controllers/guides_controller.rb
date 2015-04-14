class GuidesController < ApplicationController
  before_action :set_guide, only: [:update, :show, :edit, :destroy]
  delegate :team, to: :current_agent
  
  def index
    @guides = Guide.pages team
  end
  
  def new
    @guide = team.guides.new
  end
  
  def create
    @guide = team.guides.new guide_params
    
    if @guide.save
      flash[:created] = true
      render text:"window.location.replace('#{guide_path(@guide)}')"
    end
  end
  
  def show
    render 'edit' # TODO: change to customer preview view
  end
  
  def update
    @guide.update guide_params
  end
  
  def destroy
    @guide.delete
    redirect_to guides_path
  end
  
  def public
    public_guide = PublicGuide.new params[:team], params[:guide]
    
    if public_guide.present?
      public_guide.increment_view_count current_agent
      render text:public_guide.html # OPTIMIZE: page caching
    else
      # TODO: bootstrap 404 pages
      render file:"#{Rails.root}/public/404", layout:false, status: :not_found
    end
  end
  
  private
  
  def set_guide
    @guide = Guide.find params[:id] # TODO: change to find by slug
  end

  def guide_params
    params.require(:guide).permit %i[ name content ]
  end
end
