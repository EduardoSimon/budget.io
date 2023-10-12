class MovementsController < ApplicationController
  before_action :set_account, only: %i[update new]
  before_action :set_movement, only: %i[update]
  before_action :set_referrer, only: %i[new]
  after_action :unset_referrer, only: %i[update create]

  def new
    @movement = Movement.new(**movement_params)
  end

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

  def create
    @movement = Movement.new(movement_params)

    respond_to do |format|
      if @movement.save
        format.html do
          set_account
          redirect_to @@referrer || account_url(@account), notice: "Movement was successfully created."
        end
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private

  def movement_params
    base_params = params
      .require(:movement)
      .permit(:category_id, :account_id, :created_at, :transfer_to_account_id, :payer, :description, :amount_cents, :amount_currency, :amount)

    return base_params.merge(created_at: @movement.created_at.change(month: selected_month)) if selected_month

    base_params
  end

  def redirect_destination
    return budget_url(@account.budget, date: {month: selected_month}) if selected_month
    account_url(@movement.account)
  end

  def selected_month
    return nil if params.dig(:movement, :date).nil?

    DateTime.strptime(params[:movement][:date], "%F").month
  end

  def set_movement
    @movement = Movement.find(params[:id])
  end

  def set_account
    account_id = params[:account_id] || params.dig(:movement, :account_id)

    if account_id
      @account = Account.find(account_id)
    end
  end

  def set_referrer
    @@referrer = request.referrer
  end

  def unset_referrer
    @@referrer = nil
  end
end
