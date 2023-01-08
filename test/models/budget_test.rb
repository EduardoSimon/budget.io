require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  test "title is a mandatory parameter" do
    budget = Budget.create(title: "test")
    assert_empty budget.errors[:title]
  end

  test "has a collection of categories" do
    budget = Budget.create(title: "test")
    category = Category.create(name: "test", budget_id: budget.id)

    assert_equal(budget.categories.first.id, category.id)
    assert_equal(budget.categories.first.name, category.name)
  end

  test "has a collection of accounts" do
    institution = institutions(:revolut)
    budget = Budget.create!(title: "test")
    account = Account.create!(budget: budget, institution: institution)

    assert_equal(budget.accounts.first.id, account.id)
  end
end
