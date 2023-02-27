class AddMonetizeColumnToMovements < ActiveRecord::Migration[7.0]
  def change
    remove_column :movements, :amount_in_cents
    add_monetize :movements, :amount
  end
end
