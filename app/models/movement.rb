class Movement < ApplicationRecord
  belongs_to :account
  belongs_to :category, optional: true
  validates :payer, presence: true

  monetize :amount_cents

  def credit?
    amount < 0.0
  end

  def debit?
    amount >= 0.0
  end
end
