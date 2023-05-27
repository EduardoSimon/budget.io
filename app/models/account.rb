class Account < ApplicationRecord
  belongs_to :institution
  belongs_to :budget
  has_many :movements, dependent: :destroy
  has_many :auth_sessions, dependent: :destroy

  def authenticated?
    external_account_id.present?
  end

  def balance
    super
    Money.new(movements.sum(:amount_cents), "EUR")
  end
end
