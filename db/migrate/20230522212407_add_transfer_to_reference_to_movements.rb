class AddTransferToReferenceToMovements < ActiveRecord::Migration[7.0]
  def change
    add_reference :movements, :transfer_to_account, foreign_key: { to_table: :accounts }
  end
end
