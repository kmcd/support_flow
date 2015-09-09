class TrialsController < ApplicationController
  def new
    @trial = Trial.new team:current_team
  end

  def create
    @trial = Trial.new \
      team:current_team,
      team_name:trial_params[:team_name]

    if @trial.valid?
      @trial.start
      @current_team = @trial.team

      redirect_to team_trial_path(current_team)
    else
      render :new
    end
  end

  private

  def trial_params
    params.
      require(:trial).
      permit %i[ team_name ]
  end
end
