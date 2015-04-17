class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ edit update show ]
  
  def index
    @customers = current_team.customers.order :email_address
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
    @activities = PublicActivity::Activity.
      where owner_type:Customer, owner_id:current_team.customers.map(&:id)
  end

  private
  
  def set_customer
    @customer = current_team.customers.find params[:id]
  end

  def customer_params
    params.require(:customer).permit %i[ name company phone notes ]
  end
end
