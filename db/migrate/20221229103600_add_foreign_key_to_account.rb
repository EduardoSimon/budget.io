class AddForeignKeyToAccount < ActiveRecord::Migration[7.0]
  def change
    add_reference :accounts, :institution, foreign_key: true
  end
end
