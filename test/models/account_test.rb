require "test_helper"

class AccountTest < ActiveSupport::TestCase
  def setup
    @institution = institutions(:revolut)
    @budget = budgets(:empty)
  end

  test "belongs to a budget" do
    account = Account.create!(name: "test", institution: @institution, budget: @budget)
    assert_equal @budget.id, account.budget.id
  end

  test "has a balance" do
    account = Account.create!(
      name: "test",
      institution: @institution,
      budget: @budget,
      balance: 1912.14
    )

    assert_equal account.balance, 1912.14
  end
end
