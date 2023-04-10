class Category < ApplicationRecord
  validates :name, presence: true
  has_many :movements, dependent: :destroy
  monetize :assigned_amount_cents
  monetize :target_amount_cents
  belongs_to :budget

  def funded_percentage
    return 0.0 if target_amount_cents == 0

    ((assigned_amount_cents.to_f / target_amount_cents.to_f) * 100).clamp(0, 100)
  end
end
