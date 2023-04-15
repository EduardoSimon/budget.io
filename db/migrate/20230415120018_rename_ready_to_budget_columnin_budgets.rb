class RenameReadyToBudgetColumninBudgets < ActiveRecord::Migration[7.0]
  def change
    rename_column :budgets, :ready_to_budget_cents, :ready_to_assign_cents
    rename_column :budgets, :ready_to_budget_currency, :ready_to_assign_currency
  end
end
