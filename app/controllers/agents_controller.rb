class AgentsController < ApplicationController
  before_action :set_agent, only: %i[ edit update ]
  
  def index
    @agents = current_team.agents.order :email_address
  end

  def edit
  end
  
  def update
    @agent.update agent_params
    redirect_to edit_agent_path(@agent)
  end
  
  def activity
    @activities = PublicActivity::Activity.
      where owner_type:Agent, owner_id:current_team.agents.map(&:id)
  end

  private
  
  def set_agent
    @agent = current_team.agents.find params[:id]
  end

  def agent_params
    params.require(:agent).permit %i[ email_address name phone notes ]
  end
end
