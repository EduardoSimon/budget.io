require "test_helper"

class AccountTest < ActiveSupport::TestCase
  def setup
    @institution = institutions(:revolut)
    @budget = budgets(:empty)
    @account = Account.create!(
      name: "test",
      institution: @institution,
      budget: @budget
    )
  end

  test "belongs to a budget" do
    assert_equal @budget.id, @account.budget.id
  end

  test "its balances is the sum of its movements' amount" do
    Movement.create(account_id: @account.id, payer: "payer", amount_cents: 100_00)
    Movement.create(account_id: @account.id, payer: "payer", amount_cents: -50_00)

    assert_equal @account.balance.cents, 50_00
  end

  test "when athentication_status is 'expired'" do
  end
end
