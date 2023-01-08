class AddAccountsToAuthSession < ActiveRecord::Migration[7.0]
  def change
    add_column :auth_sessions, :external_account_id, :string
  end
end
