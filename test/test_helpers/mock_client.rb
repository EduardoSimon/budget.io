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

      def requisition
        {
          id: "ca6352b7-ac60-455a-bbb2-bdbedad64c1d",
          created: "2023-10-09T20:47:40.522084Z",
          redirect: "http://localhost:3000",
          status: "EX",
          institution_id: "ING_INGDESMM",
          agreement: "14903f95-5061-4cdd-8431-2936ea34a119",
          reference: "1_1696884447",
          accounts: ["4f487e62-4e4f-432b-8c28-cfa9689fb657"],
          link: "https://ob.gocardless.com/psd2/start/d217935b-2f77-4a85-b3dc-0b27c0eab56b/ING_INGDESMM",
          ssn: nil,
          account_selection: false,
          redirect_immediate: false
        }
      end
    end
  end
end
