require "test_helper"
require "test_helpers/mock_client"

class OpenBankingConnectorTest < ActiveSupport::TestCase
  class FetchMovementsTest < ActiveSupport::TestCase
    setup do
      @client_mock = Minitest::Mock.new
      @client_mock.expect(:generate_token, "wadus")
      freeze_time
    end

    teardown do
      unfreeze_time
    end

    test "when the account does not exists raises an error" do
      error = {"summary" => "Invalid Account ID", "detail" => "1 is not a valid Account UUID. ", "status_code" => 400}
      balances_mock = Minitest::Mock.new
      balances_mock.expect(:get_balances, error)
      @client_mock.expect(:account, balances_mock, ["1"])

      ::Nordigen::NordigenClient.stub(:new, @client_mock) do
        exception = assert_raises(StandardError) do |e|
          OpenBankingConnector.new.fetch_movements(external_account_id: "1")
        end

        assert_equal exception.message, error.to_json
      end
    end

    test "returns the main balance of the given existent account as a float number, the currency and the transactions" do
      balances_response = {"balances" => [{"balanceAmount" => {"amount" => "896.13", "currency" => "EUR"}, "balanceType" => "information", "lastChangeDateTime" => "2023-10-12T00:00:00Z"}, {"balanceAmount" => {"amount" => "935.37", "currency" => "EUR"}, "balanceType" => "interimBooked", "lastChangeDateTime" => "2023-10-12T00:00:00Z"}]}

      account_mock = Minitest::Mock.new
      account_mock.expect(:get_balances, balances_response.deep_symbolize_keys)
      account_mock.expect(:get_transactions, {"transactions" => {"booked" => MockClient::Stubs.transactions}}, date_from: String, date_to: String)

      @client_mock.expect(:account, account_mock, ["1"])

      ::Nordigen::NordigenClient.stub(:new, @client_mock) do
        response = OpenBankingConnector.new.fetch_movements(external_account_id: "1")

        assert_equal response.balance, 896.13
        assert_equal response.currency, "EUR"

        assert_equal response.transactions.first[:id], 0
        assert_equal response.transactions.first[:amount], 100.0
        assert_equal response.transactions.first[:date], "2023-07-24"
        assert_equal response.transactions.first[:description], "Pago en EL CORTE INGLES"

        assert_equal response.transactions.second[:id], 1
        assert_equal response.transactions.second[:amount], 200.0
        assert_equal response.transactions.second[:date], "2023-07-24"
        assert_equal response.transactions.second[:description], "Pago en EL CORTE INGLES"
      end
    end
  end
end
