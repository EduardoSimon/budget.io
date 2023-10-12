class MonthlyAssignment < ApplicationRecord
  belongs_to :category
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :end_date, comparison: {greater_than: :start_date}
  scope :between_dates, ->(from_date, to_date) { where("start_date = ? AND end_date = ?", from_date, to_date) }

  monetize :amount_cents, allow_nil: false
end
