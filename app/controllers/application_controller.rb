class ApplicationController < ActionController::Base
  include Authenticatable
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private
  
  def search_query
    # TODO: move default 'sort:new' to lib/searchable.rb
    params[:q].present? ? params[:q] : 'sort:new'
  end
end
