class RenameBalanceColumnInAccounts < ActiveRecord::Migration[7.0]
  def change
    rename_column :accounts, :balance, :reported_balance
  end
end
