class Budget < ApplicationRecord
  validates :title, presence: true
  has_many :categories, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :movements, through: :accounts

  def uncategorized_movements
    movements.where(category_id: nil)
  end

  def ready_to_budget
    debits_without_category_sum = movements.debits.without_category.sum("amount_cents")
    assigned_cents_in_categories = categories.sum("assigned_amount_cents")
    ready_to_budget_cents = debits_without_category_sum - assigned_cents_in_categories
    Money.new(ready_to_budget_cents, ready_to_budget_currency)
  end
end
