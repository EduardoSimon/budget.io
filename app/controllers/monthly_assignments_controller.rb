class MonthlyAssignmentsController < ApplicationController
  def show
    @assignment = MonthlyAssignment.find(params[:id])

    respond_to do |format|
      if @assignment
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @category = Category.new
  end

  def update
    @assignment = MonthlyAssignment.find(params[:id])

    respond_to do |format|
      if @assignment.update!(assignment_params)
        format.json { render :show, status: :ok, location: @assignment }
      else
        format.json { render json: @assignment.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def assignment_params
    params.permit(:amount_cents, :end_date, :start_date)
  end
end
