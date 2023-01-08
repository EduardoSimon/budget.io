class MovementsController < ApplicationController
  def update
    respond_to do |format|
      if @movement.update(movement_params)
        format.html { redirect_to account_movement_url(@account, @movement), notice: "Account was successfully updated." }
        format.json { render :show, status: :ok, location: @movement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movement.errors, status: :unprocessable_entity }
      end
    end
  end
end
