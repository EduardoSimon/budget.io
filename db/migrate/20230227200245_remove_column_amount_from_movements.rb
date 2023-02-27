class RemoveColumnAmountFromMovements < ActiveRecord::Migration[7.0]
  def change
    remove_column :movements, :amount
  end
end
