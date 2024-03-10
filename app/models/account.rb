class Account < ApplicationRecord
  belongs_to :institution
  belongs_to :budget
  has_many :movements, dependent: :destroy
  has_many :auth_sessions, -> { order(created_at: :desc) }, dependent: :destroy
  monetize :reported_balance_cents

  # https://developer.gocardless.com/bank-account-data/statuses
  AUTHENTICATED_STATUS = "LN".freeze

  def authenticated?
    return false unless external_account_id.present?

    requisition_id = auth_sessions&.first&.external_id
    return false unless requisition_id.present?

    requisition = OpenBankingConnector.new.fetch_requisition(requisition_id)

    requisition[:status] == AUTHENTICATED_STATUS
  end

  def balance
    Money.new(movements.sum(:amount_cents), "EUR")
  end
end
