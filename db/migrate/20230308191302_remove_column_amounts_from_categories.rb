class RemoveColumnAmountsFromCategories < ActiveRecord::Migration[7.0]
  def change
    remove_column :categories, :assigned_amount
    remove_column :categories, :target_amount

    add_monetize :categories, :assigned_amount
    add_monetize :categories, :target_amount
  end
end
