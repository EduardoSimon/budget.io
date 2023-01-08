class AddBudgetReferenceToCategory < ActiveRecord::Migration[7.0]
  def change
    change_table :categories do |t|
      t.belongs_to :budget, index: true, foreign_key: true, dependent: :destroy
    end
  end
end
