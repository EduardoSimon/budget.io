class MockClient
  def init_auth_session(*)
    OpenBankingConnector::AuthSession.new(url: "url1", id: "id")
  end

  def fetch_session_result(*)
    OpenBankingConnector::AuthSession.new(url: "url1", id: "id", accounts: ["account1"])
  end

  def fetch_movements(*)
    transactions = []
    2.times do |i|
      transactions.push({
        id: i,
        date: Time.now.utc.iso8601,
        amount: Money.new(10000 * i, "EUR"),
        payer: "payer",
        description: "description"
      })
    end
    OpenBankingConnector::AccountResponse.new(
      transactions: transactions,
      balance: 500.00,
      currency: "EUR"
    )
  end

  class Stubs
    class << self
      def transactions
        transactions = []
        2.times do |i|
          transactions.push({
            "transactionId" => i,
            "bookingDate" => "2023-07-24",
            "transactionAmount" => {"amount" => ((i + 1) * 100.0).to_s, "currency" => "EUR"},
            "remittanceInformationUnstructured" => "Pago en EL CORTE INGLES"
          })
        end
        transactions
      end
    end
  end
end
