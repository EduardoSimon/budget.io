class Movement < ApplicationRecord
  belongs_to :account
  belongs_to :category, optional: true
  validates :payer, presence: true

  monetize :amount_cents
  scope :debits, -> { where("amount_cents >= 0") }
  scope :credits, -> { where("amount_cents < 0") }
  scope :without_category, -> { where("category_id IS NULL") }
  scope :between_dates, ->(from_date, to_date) { where("created_at BETWEEN ? AND ?", from_date, to_date) }

  def credit?
    amount < 0.0
  end

  def debit?
    amount >= 0.0
  end
end
