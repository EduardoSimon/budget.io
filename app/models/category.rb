class Category < ApplicationRecord
  validates :name, presence: true
  has_many :movements, dependent: :destroy
  has_many :monthly_assignments, dependent: :destroy
  monetize :target_amount_cents
  belongs_to :budget

  def funded?(current_month)
    assigned_amount_in(current_month).cents >= target_amount_cents
  end

  def overspent?(current_month)
    spent_amount_cents.abs > assigned_amount_in(current_month).cents
  end

  def in_spending?(month_date)
    spent_percentage_in_month(month_date) > 0 && spent_percentage_in_month(month_date) < 100.0
  end

  def spent_percentage_in_month(month_date)
    (spent_amount_cents_in_month(month_date).abs.to_f / assigned_amount_in(month_date).cents.to_f) * 100.0
  end


  def spent_amount_in_month(month_date)
    Money.new(spent_amount_cents_in_month(month_date), movements.first&.amount_currency || "EUR")
  end

  def spent_amount_cents_in_month(month_date)
    if month_date
      next_month_date = month_date.beginning_of_month.next_month

      movements
        .between_dates(month_date.beginning_of_month, next_month_date)
        .pluck(Arel.sql('sum(abs(amount_cents))::integer')).first || 0
    else
      movements.pluck(Arel.sql('sum(abs(amount_cents))::integer')).first || 0
    end
  end

  def spent_amount_cents
    movements.pluck(Arel.sql('sum(abs(amount_cents))::integer')).first || 0
  end

  def assignment_for_month(month_date)
    next_month_date = month_date.beginning_of_month.next_month

    stored_assignment = monthly_assignments.between_dates(month_date, next_month_date).order(:start_date).first

    if !stored_assignment
      return MonthlyAssignment.create!(category_id: id, amount_cents: 0, amount_currency: 'EUR', start_date: month_date,end_date: next_month_date)
    end

    return stored_assignment
  end

  def assigned_amount_in(month_date)
    next_month_date = month_date.beginning_of_month.next_month

    stored_assignment = monthly_assignments.between_dates(month_date, next_month_date).first
    
    return Money.new(0, "EUR") unless stored_assignment

    stored_assignment.amount
  end
end
