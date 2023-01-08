class AddExternalAccountIdToAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :external_account_id, :string
  end
end
