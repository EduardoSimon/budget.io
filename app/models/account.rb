class Account < ApplicationRecord
  belongs_to :institution
  belongs_to :budget
  has_many :movements, dependent: :destroy
  has_many :auth_sessions, dependent: :destroy
  monetize :reported_balance_cents

  def authenticated?
    ## TODO improve logic here to check status of current agreement
    ## https://github.com/EduardoSimon/budget.io/issues/25
    external_account_id.present?
  end

  def balance
    Money.new(movements.sum(:amount_cents), "EUR")
  end
end
