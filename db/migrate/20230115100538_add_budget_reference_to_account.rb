class AddBudgetReferenceToAccount < ActiveRecord::Migration[7.0]
  def change
    add_reference :accounts, :budget, foreign_key: true, null: true
  end
end
