class MovementsController < ApplicationController
  before_action :set_movement, only: %i[update]

  def update
    respond_to do |format|
      if @movement.update(movement_params)
        format.html { redirect_to budget_url(@account.budget, date: { month: selected_month }), notice: "Account was successfully updated." }
        format.json { render :show, status: :ok, location: @movement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movement.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def movement_params
    params
      .require(:movement)
      .permit(:category_id, :account_id, :created_at)
      .merge(created_at: @movement.created_at.change(month: selected_month))
  end
  
  def selected_month
    DateTime.strptime(params[:movement][:date], '%F').month
  end

  def set_movement
    @movement = Movement.find(params[:id])
    @account = Account.find(params[:account_id])
  end
end
