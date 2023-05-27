class MovementsController < ApplicationController
  before_action :set_movement, only: %i[update]

  def update
    respond_to do |format|
      if @movement.update(movement_params)
        format.html { redirect_to redirect_destination, notice: "Account was successfully updated." }
        format.json { render :show, status: :ok, location: @movement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movement.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def movement_params
    base_params = params
      .require(:movement)
      .permit(:category_id, :account_id, :created_at, :transfer_to_account_id)

    return base_params.merge(created_at: @movement.created_at.change(month: selected_month)) if selected_month

    base_params
  end

  def redirect_destination
    return budget_url(@account.budget, date: { month: selected_month }) if selected_month
    return account_url(@movement.account)
  end
  
  def selected_month
    return nil if params.dig(:movement,:date).nil?

    DateTime.strptime(params[:movement][:date], '%F').month
  end

  def set_movement
    @movement = Movement.find(params[:id])
    @account = Account.find(params[:account_id])
  end
end
