class AddMonetizeColumnToBudgets < ActiveRecord::Migration[7.0]
  def change
    add_monetize :budgets, :ready_to_budget
  end
end
