class AddExternalIdToMovements < ActiveRecord::Migration[7.0]
  def change
    add_column :movements, :external_id, :string
    add_index :movements, :external_id
  end
end
