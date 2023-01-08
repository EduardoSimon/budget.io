class AddCategoryReferenceToMovements < ActiveRecord::Migration[7.0]
  def change
    add_reference :movements, :category, foreign_key: true, null: true
  end
end
