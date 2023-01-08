class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.decimal :assigned_amount, null: false, default: 0.0, precision: 8, scale: 2
      t.decimal :target_amount, precision: 8, scale: 2

      t.timestamps
    end
  end
end
