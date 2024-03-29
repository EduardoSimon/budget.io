require "test_helper"

class BudgetTest < ActiveSupport::TestCase
  test "title is a mandatory parameter" do
    budget = Budget.create(title: "test")
    assert_empty budget.errors[:title]
  end

  test "has a collection of categories" do
    budget = Budget.create(title: "test")
    category = Category.create(name: "test", budget_id: budget.id)
    categories = budget.categories.all

    assert_equal(categories.length, 2)
    assert_equal(budget.categories.find_by(name: "test").id, category.id)
  end

  test "has a collection of accounts" do
    institution = institutions(:revolut)
    budget = Budget.create!(title: "test")
    account = Account.create!(budget: budget, institution: institution)

    assert_equal(budget.accounts.first.id, account.id)
  end

  class UncategorizedMovementsTest < ActiveSupport::TestCase
    setup do
      @institution = institutions(:revolut)
      @budget = Budget.create!(title: "test")
      @month = DateTime.now.beginning_of_month
      @account = Account.create!(budget: @budget, institution: @institution)
      @another_account = Account.create!(budget: @budget, institution: @institution)
    end

    test ".uncategorized_movements_in returns movements between dates" do
      movement_amount_cents = 10000

      movement_1 = Movement.create!(account: @account,
        amount_cents: movement_amount_cents,
        payer: "with category")
      movement_2 = Movement.create!(account: @account,
        amount_cents: movement_amount_cents,
        payer: "with category",
        created_at: @month.next_month)

      assert_includes @budget.uncategorized_movements_in(@month), movement_1
      assert_not_includes @budget.uncategorized_movements_in(@month), movement_2
    end

    test ".uncategorized_movements_in excludes transfers" do
      movement_amount_cents = 10000

      movement_1 = Movement.create!(account: @account,
        amount_cents: movement_amount_cents,
        payer: "transfer",
        transfer_to_account_id: @another_account.id)
      movement_2 = Movement.create!(account: @account,
        amount_cents: movement_amount_cents,
        payer: "with category")

      assert_not_includes @budget.uncategorized_movements_in(@month), movement_1
      assert_includes @budget.uncategorized_movements_in(@month), movement_2
    end
  end

  test "has a category named Ready to Assign when created" do
    budget = Budget.create(title: "test")

    assert_equal(
      budget.categories.where(id: budget.ready_to_assign_category_id).first.id,
      budget.ready_to_assign_category_id
    )
  end

  test "ready to assign amount is the sum of movements in ready to assign category minus the sum of assigned amounts in categories" do
    movement_amount_cents = 10000
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    institution = institutions(:revolut)
    budget = Budget.create(title: "test")
    category = Category.create(name: "test", budget_id: budget.id)
    MonthlyAssignment.create!(category: category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(10000, "EUR"))

    account = Account.create!(budget: budget, institution: institution)
    Movement.create!(account: account, category_id: budget.ready_to_assign_category_id,
      amount_cents: movement_amount_cents, payer: "with category", created_at: beginning_of_month)
    Movement.create!(account: account, category_id: budget.ready_to_assign_category_id,
      amount_cents: movement_amount_cents, payer: "with category", created_at: beginning_of_month)
    Movement.create!(account: account, amount_cents: movement_amount_cents,
      payer: "without category", created_at: beginning_of_month)

    assert_equal(10000, budget.ready_to_assign.cents)
  end

  test "needs_reconciliation? returns true when a reported balance mismatches with the budget's one" do
    budget = create(:budget)
    account = create(:account, reported_balance: Money.new(50_00, "EUR"), budget: budget)
    create_list(:movement, 2, amount: Money.new(20_00, "EUR"), account: account)

    assert(budget.needs_reconciliation?)
  end

  test "needs_reconciliation? returns false when no reported balance mismatches with the budget's one" do
    budget = create(:budget)
    account = create(:account, reported_balance: Money.new(40_00, "EUR"), budget: budget)
    create_list(:movement, 2, amount: Money.new(20_00, "EUR"), account: account)

    assert_equal(false, budget.needs_reconciliation?)
  end
end
