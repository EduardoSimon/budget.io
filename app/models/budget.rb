class Budget < ApplicationRecord
  validates :title, presence: true
  has_many :categories, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :movements, through: :accounts

  def uncategorized_movements
    movements.where(category_id: nil)
  end
end
