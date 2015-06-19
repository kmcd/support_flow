class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ edit update show ]
  helper_method :search_query
  
  def index
    @customers = CustomerSearch.
      new(search_query, current_team, params[:page]).customers
  end

  def show
  end
  
  def edit
  end
  
  def update
    if @customer.update customer_params
      flash[:saved] = true
      redirect_to edit_customer_path(@customer)
    end
    # TODO: error handling - only json profile update?
  end
  
  def activity
    @activities = Activity.
      where owner_type:Customer, owner_id:current_team.customers.map(&:id)
  end

  private
  
  def set_customer
    @customer = current_team.customers.find params[:id]
  end

  def customer_params
    params.require(:customer).permit %i[ name company phone notes ]
  end
  
  def search_query
    # TODO: remove sort:new from default search box
    params[:q].present? ? params[:q] : 'sort:new'
  end
end
