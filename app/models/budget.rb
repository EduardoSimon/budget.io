class Budget < ApplicationRecord
  validates :title, presence: true
  has_many :categories, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :movements, -> { includes(:account) }, through: :accounts

  def uncategorized_movements
    movements.where(category_id: nil)
  end

  def ready_to_assign
    ready_to_assign_cents = Category.find(ready_to_assign_category_id).spent_amount_cents
    assigned_cents_in_categories = categories
      .where
      .not(id: ready_to_assign_category_id)
      .sum('assigned_amount_cents')
    Money.new(ready_to_assign_cents - assigned_cents_in_categories, ready_to_assign_currency)
  end
end
