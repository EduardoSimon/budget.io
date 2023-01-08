class PullAccountMovementsJob < ApplicationJob
  queue_as :default

  def perform(account_id:)
    account = Account.find(account_id)

    # TODO get the latest movement and its date to optimize
    result = OpenBankingConnector.new.fetch_movements(
      external_account_id: account.external_account_id
    )

    account.update!(balance: result.balance)

    result.transactions.each do |t|
      Rails.logger.info(t)

      movement = Movement.find_by(external_id: t[:id])
      booking_date = Time.find_zone("UTC").parse(t[:date])

      if !movement
        Movement.create!(
          budget: account.budget,
          description: t[:description],
          payer: t[:payer] || "wadus",
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
