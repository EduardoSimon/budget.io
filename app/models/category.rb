class Category < ApplicationRecord
  validates :name, presence: true
  has_many :movements, dependent: :destroy
  monetize :assigned_amount_cents
  monetize :target_amount_cents
  belongs_to :budget

  def funded_percentage
    (spent_amount_cents.to_f / assigned_amount_cents.to_f * 100).clamp(0, 100)
  end

  def funded?
    funded_percentage >= 100
  end

  def overspent?
    (spent_amount_cents.to_f / assigned_amount_cents.to_f) > 1
  end

  def spent_amount_cents
    movements.credits.sum("amount_cents") * -1
  end

  def spent_amount
    Money.new(spent_amount_cents, "EUR")
  end
end
