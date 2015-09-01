class TeamsController < ApplicationController
  helper_method :dashboard

  def show
  end

  def edit
  end

  def update
    if current_team.update name:params[:team_name_update]
      flash[:notice] = "Saved"
    else
      flash[:error_messages] = current_team.errors.full_messages
    end

    redirect_to edit_team_path(current_team.name)
  end

  def dashboard
    @dashboard ||= Dashboard.new current_team, params[:page]
  end
end
