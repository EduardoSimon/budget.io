class AddContraMovementIdToMovements < ActiveRecord::Migration[7.0]
  def change
    add_reference :movements, :contra_movement
  end
end
