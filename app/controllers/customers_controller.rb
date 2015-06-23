class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ edit update show ]
  helper_method :search_query

  def new
    @customer = Customer.new
  end

  def create
    @customer = current_team.customers.new customer_params

    if @customer.save
      redirect_to customer_path(@customer)
    else
      render :new
    end
  end

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
      redirect_to customer_path(@customer)
    else
      render :edit
    end
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
    params.require(:customer).permit %i[
      name
      phone
      email_address
      company
      label_list
      notes
    ]
  end
end
