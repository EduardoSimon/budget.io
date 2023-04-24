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

  def in_spending?(month_date)
    spent_percentage_in_month(month_date) > 0 && spent_percentage_in_month(month_date) < 100.0
  end

  def spent_percentage_in_month(month_date)
    (spent_amount_cents_in_month(month_date).abs.to_f / assigned_amount_cents.to_f) * 100.0
  end


  def spent_amount_in_month(month_date)
    Money.new(spent_amount_cents_in_month(month_date), movements.first&.amount_currency || "EUR")
  end

  def spent_amount_cents_in_month(month_date)
    if month_date
      next_month_date = month_date.beginning_of_month.next_month

      movements
        .between_dates(month_date, next_month_date)
        .pluck(Arel.sql('sum(abs(amount_cents))::integer')).first || 0
    else
      movements.pluck(Arel.sql('sum(abs(amount_cents))::integer')).first || 0
    end
  end

  def spent_amount_cents
    movements.pluck(Arel.sql('sum(abs(amount_cents))::integer')).first || 0
  end
end
