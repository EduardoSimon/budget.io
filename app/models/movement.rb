class Movement < ApplicationRecord
  belongs_to :account
  belongs_to :category, optional: true
  validates :payer, presence: true

  monetize :amount_cents
  scope :debits, -> { where("amount_cents >= 0") }
  scope :credits, -> { where("amount_cents < 0") }
  scope :without_category, -> { where("category_id IS NULL") }
  scope :between_dates, ->(from_date, to_date) { where("movements.created_at BETWEEN ? AND ?", from_date, to_date) }

  before_update :create_associated_movement_if_set_as_transfer

  def credit?
    amount < 0.0
  end

  def debit?
    amount >= 0.0
  end

  private
  
  def create_associated_movement_if_set_as_transfer
    if transfer? && !contra_movement_stored?
      cloned_attributes = attributes.with_indifferent_access
        .merge(amount_cents: amount_cents * -1, account_id: transfer_to_account_id)
        .except(:id,:transfer_to_account_id)
      contra_movement = Movement.create!(cloned_attributes)
      self.contra_movement_id = contra_movement.id
    end
  end

  def transfer?
    !transfer_to_account_id.nil?
  end

  def contra_movement_stored?
    !contra_movement_id.nil?
  end
end
