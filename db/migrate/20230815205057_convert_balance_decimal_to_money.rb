class ConvertBalanceDecimalToMoney < ActiveRecord::Migration[7.0]
  def up
    add_monetize :accounts, :reported_balance

    Account.find_each do |account|
      account.update!(reported_balance: Money.new(account.balance * 100))
    end

    remove_column :accounts, :balance
  end

  def down
    add_column :accounts, :balance, :decimal, precision: 8, scale: 2

    Account.find_each do |account|
      account.update!(balance: account.reported_balance.cents / 100.0)
    end

    remove_monetize :accounts, :reported_balance
  end
end
