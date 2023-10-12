class AddTableMontlyAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :monthly_assignments do |t|
      t.monetize :amount,
        amount: {null: false, default: nil},
        currency: {null: false, default: nil}
      t.date :start_date
      t.date :end_date
      t.references :category, foreign_key: true

      t.timestamps
    end
  end
end
