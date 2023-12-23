class AddBudgetReferenceToMovement < ActiveRecord::Migration[7.0]
  def change
    change_table :movements do |t|
      t.belongs_to :budget, index: true, foreign_key: true
    end
  end
end
