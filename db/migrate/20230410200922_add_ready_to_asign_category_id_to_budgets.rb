class AddReadyToAsignCategoryIdToBudgets < ActiveRecord::Migration[7.0]
  def up
    add_column :budgets, :ready_to_assign_category_id, :integer
  end
end
