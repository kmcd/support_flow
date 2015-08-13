module Attachable
  MAX_ATTACHMENTS_SIZE = 25.megabytes
  extend ActiveSupport::Concern
  include ActionView::Helpers::NumberHelper

  included do
    helper_method :attachments,
      :session_attachment_ids,
      :attachments_size,
      :max_attachments_size,
      :attachments_under_limit?,
      :uploads_under_limit?
  end

  def attachments
    ActiveRecord::Base.uncached do
      current_team.attachments.where id:session_attachment_ids
    end
  end

  def attachments_size
    attachments.map(&:size).sum
  end

  def attachments_under_limit?
    attachments_size < MAX_ATTACHMENTS_SIZE
  end

  def session_attachment_ids
    session[:attachment_ids] ||= []
    session[:attachment_ids]
  end

  def uploads_under_limit?
    uploaded = outbound_email_params[:attachments].map(&:size).sum
    uploaded < MAX_ATTACHMENTS_SIZE
  end
end
