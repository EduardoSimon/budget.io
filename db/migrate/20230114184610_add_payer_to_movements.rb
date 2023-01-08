class AddPayerToMovements < ActiveRecord::Migration[7.0]
  def change
    add_column :movements, :payer, :string, null: false
  end
end
