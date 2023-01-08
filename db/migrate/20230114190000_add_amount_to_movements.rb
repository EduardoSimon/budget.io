class AddAmountToMovements < ActiveRecord::Migration[7.0]
  def change
    add_column :movements, :amount, :decimal, precision: 8, scale: 2, null: false
  end
end
