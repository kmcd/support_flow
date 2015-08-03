class NotificationsController < ApplicationController
  # GET /notifications/1/edit
  def edit
  end

  # PATCH/PUT /notifications/1
  def update
    if current_agent.update notification_policy:notification_params
      redirect_to edit_team_notifications_path(current_team),
        notice: 'Email notifications successfully updated'
    else
      render :edit
    end
  end

  private

  def notification_params
    return {} unless params[:notification_policy].present?

    params.
      require(:notification_policy).
      permit %i[ open assign close ]
  end
end
