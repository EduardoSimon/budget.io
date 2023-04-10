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

  test "ready to budget amount is the difference between the sum of debits without category and the sum of assigned cents in every category" do
    movement_amount = 10000
    category_assigned_amount = 5000

    institution = institutions(:revolut)
    budget = Budget.create(title: "test")
    category = Category.create!(name: "test", budget_id: budget.id, assigned_amount_cents: category_assigned_amount)
    account = Account.create!(budget: budget, institution: institution)
    Movement.create!(account: account, category: category, amount_cents: movement_amount, payer: "with category")
    Movement.create!(account: account, amount_cents: movement_amount, payer: "without category")
    Movement.create!(account: account, amount_cents: movement_amount, payer: "without category")

    assert_equal(budget.ready_to_budget, Money.new((movement_amount * 2) - category_assigned_amount, budget.ready_to_budget_currency))
  end
end
