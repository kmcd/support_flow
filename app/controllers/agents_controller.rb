class AgentsController < ApplicationController
  before_action :set_agent, only: %i[ edit update show ]
  helper_method :dashboard

  def index
    @agents = current_team.agents
  end
  
  def new
    @agent = current_team.agents.new
  end
  
  def create
    @agent = current_team.agents.new agent_params.
      merge!( invitor:current_agent )
    
    if @agent.save
      redirect_to team_agents_path(current_team)
    else
      flash[:errors] = @agent.errors.full_messages
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    @agent.update agent_params
    redirect_to agent_path @agent
  end

  def activity
    @activities = Activity.
      where owner_type:Agent, owner_id:current_team.agents.map(&:id)
  end

  private

  def set_agent
    @agent = current_team.agents.find params[:id]
  end

  def agent_params
    params.require(:agent).permit %i[ name phone email_address notes ]
  end

  def dashboard
    @dashboard ||= Dashboard.new current_team
  end
end
