class CreateMovements < ActiveRecord::Migration[7.0]
  def change
    create_table :movements do |t|
      t.integer :amount_in_cents
      t.boolean :reconciled

      t.timestamps
    end
  end
end
