require "test_helper"
require "test_helpers/mock_client"

class AccountMovementsPullerJobTest < ActiveJob::TestCase
  def setup
    @account = create(:account)
    freeze_time
    @uuid = SecureRandom.uuid
  end

  teardown do
    unfreeze_time
  end

  def subject(&block)
    OpenBankingConnector.stub :new, MockClient.new do
      SecureRandom.stub :uuid, @uuid do
        yield block if block
      end
    end
  end

  test "creates a movement for every transaction fetched by the open banking connector" do
    subject do
      PullAccountMovementsJob.perform_now(account_id: @account.id)
    end

    movements = @account.movements.reload
    assert_equal movements.length, 2

    assert_equal movements.first.created_at, Time.now.utc.iso8601
    assert_equal movements.first.external_id, "0"
    assert_equal movements.first.amount, Money.new(0, "EUR")

    assert_equal movements.second.created_at, Time.now.utc.iso8601
    assert_equal movements.second.external_id, "1"
    assert_equal movements.second.amount, Money.new(100_00, "EUR")
  end

  test "updates the reported balance of the given account" do
    subject do
      PullAccountMovementsJob.perform_now(account_id: @account.id)
    end

    assert_equal(@account.reload.reported_balance, Money.new(500_00, "EUR"))
  end
end
