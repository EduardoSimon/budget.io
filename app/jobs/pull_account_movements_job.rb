class PullAccountMovementsJob < ApplicationJob
  queue_as :default

  def perform(account_id:)
    account = Account.find(account_id)

    # TODO get the latest movement and its date to optimize
    result = OpenBankingConnector.new.fetch_movements(
      external_account_id: account.external_account_id
    )

    reported_balance = Money.new(result.balance * 100, "EUR")
    account.update!(reported_balance: reported_balance)

    result.transactions.each do |t|
      Rails.logger.info(t)

      movement = Movement.find_by(external_id: t[:id])
      booking_date = Time.find_zone("UTC").parse(t[:date])

      if !movement
        Movement.create!(
          account: account,
          description: t[:description],
          payer: t[:payer] || "Unknown Payer",
          amount: t[:amount],
          created_at: booking_date,
          external_id: t[:id]
        )
      end
    end

    # transactions.booked.[]
    # logger.info(transactions)
  end
end
