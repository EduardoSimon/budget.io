class RemoveBudgetReferenceFromMovements < ActiveRecord::Migration[7.0]
  def change
    remove_reference :movements, :budget, index: true, foreign_key: true
    add_reference :movements, :account, index: true, foreign_key: true
  end
end
