class Category < ApplicationRecord
  validates :name, presence: true
  has_many :movements, dependent: :destroy
  monetize :assigned_amount_cents
  monetize :target_amount_cents
  belongs_to :budget

  def funded?
    assigned_amount_cents >= target_amount_cents
  end

  def overspent?
    spent_amount_cents.abs > assigned_amount_cents
  end

  def in_spending?
    spent_percentage > 0 && spent_percentage < 100.0
  end

  def spent_percentage
    (spent_amount_cents.abs.to_f / assigned_amount_cents.to_f) * 100.0
  end


  def spent_amount
    Money.new(spent_amount_cents, movements.first.amount_currency)
  end

  def spent_amount_cents
    movements.pluck(Arel.sql('sum(abs(amount_cents))::integer')).first
  end

  def spent_amount
    Money.new(spent_amount_cents, "EUR")
  end
end
