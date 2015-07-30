class ReplyTemplatesController < ApplicationController
  before_action :set_reply_template, only: [:show, :edit, :update, :destroy]

  # GET /reply_templates
  def index
    @reply_templates = current_team.reply_templates.all
  end

  # GET /reply_templates/1
  def show
  end

  # GET /reply_templates/new
  def new
    @reply_template = current_team.reply_templates.new
  end

  # GET /reply_templates/1/edit
  def edit
  end

  # POST /reply_templates
  def create
    @reply_template = current_team.reply_templates.new reply_template_params

    if @reply_template.save
      redirect_to team_reply_templates_path(current_team),
        notice: 'Reply template was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /reply_templates/1
  def update
    if @reply_template.update reply_template_params
      redirect_to @reply_template, notice: 'Reply template was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /reply_templates/1
  def destroy
    @reply_template.destroy
    redirect_to team_reply_templates_url(current_team),
      notice: 'Reply template was successfully destroyed.'
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_reply_template
    @reply_template = current_team.reply_templates.find params[:id]
  end

  # Only allow a trusted parameter "white list" through.
  def reply_template_params
    params.
      require(:reply_template).
      permit %i[ name template ]
  end
end
