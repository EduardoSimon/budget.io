class Category < ApplicationRecord
  validates :name, presence: true

  has_many :movements, dependent: :destroy
  belongs_to :budget

  def assigned_amount
    super
    Money.from_cents(movements.sum("amount_cents"))
  end
end
