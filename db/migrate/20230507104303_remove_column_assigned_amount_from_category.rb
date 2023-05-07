class RemoveColumnAssignedAmountFromCategory < ActiveRecord::Migration[7.0]
  def change
    remove_monetize :categories, :assigned_amount
  end
end
