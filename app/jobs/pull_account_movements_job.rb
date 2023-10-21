class PullAccountMovementsJob < ApplicationJob
  queue_as :default

  def perform(account_id:)
    account = Account.find(account_id)

    ## https://github.com/EduardoSimon/budget.io/issues/29
    result = OpenBankingConnector.new.fetch_movements(
      account: account
    )

    Rails.logger.info({balance: result.balance})

    reported_balance = Money.new((result.balance * 100).to_i, "EUR")
    account.update!(reported_balance: reported_balance)

    result.transactions.each do |t|
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
