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

  test "ready to assign amount is the sum of movements in ready to assign category" do
    movement_amount_cents = 10000

    institution = institutions(:revolut)
    budget = Budget.create(title: "test")
    ready_to_assign_category = Category.create!(name: "Ready To Assign", budget_id: budget.id)
    budget.update!(ready_to_assign_category_id: ready_to_assign_category.id)

    account = Account.create!(budget: budget, institution: institution)
    Movement.create!(account: account, category: ready_to_assign_category, amount_cents: movement_amount_cents, payer: "with category")
    Movement.create!(account: account, category: ready_to_assign_category, amount_cents: movement_amount_cents, payer: "with category")
    Movement.create!(account: account, amount_cents: movement_amount_cents, payer: "without category")

    assert_equal(movement_amount_cents * 2, budget.ready_to_assign_cents)
  end
end
