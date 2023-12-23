require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @budget = budgets(:empty)
    @account = accounts(:one)
    @category = Category.create!(name: "test", budget: @budget)
  end

  teardown do
    @category.destroy!
    Movement.destroy_all
    @account.destroy!
    @budget.destroy!
    MonthlyAssignment.destroy_all
  end

  test "name is a mandatory parameter" do
    category = Category.create(name: "test")
    assert_empty category.errors[:name]
  end

  test "funded? returns true when the assigned amount in a month is GREATER than the target amount" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(60000, "EUR"))

    @category.update!(target_amount_cents: 50000)

    assert_equal(@category.funded?(beginning_of_month), true)
  end

  test "funded? returns true when the assigned amount in a month is EQUAL than the target amount" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(50000, "EUR"))

    @category.update!(target_amount_cents: 50000)

    assert_equal(@category.funded?(beginning_of_month), true)
  end

  test "funded? returns false when the assigned amount in a month is LESS than the target amount" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)

    @category.update!(target_amount_cents: 60000)

    assert_equal(@category.funded?(beginning_of_month), false)
  end

  test "funded? returns false when the category is overspent" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(10000, "EUR"))

    assert_equal(@category.funded?(beginning_of_month), false)
  end

  test "overspent? returns true when the spent amount is GREATER than the assigned amount in a month" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(10000, "EUR"))

    assert_equal(@category.overspent?(beginning_of_month), true)
  end

  test "overspent? returns false when the spent amount is SMALLER than the assigned amount in a month" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(40000, "EUR"))

    assert_equal(@category.overspent?(beginning_of_month), false)
  end

  test "overspent? returns false when the spent amount is EQUAL to the the assigned_amount_cents" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(20000, "EUR"))

    assert_equal(@category.overspent?(beginning_of_month), false)
  end

  test "overspent? returns false when the target_amount is 0 and the assignment is 0 and activity is greater than 0" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    @category.update!(target_amount_cents: 0)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(0, "EUR"))

    assert_equal(@category.overspent?(beginning_of_month), false)
  end

  test "overspent? returns true true the target_amount is 0 and the assignment is 0 and activity is greater than 0" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    @category.update!(target_amount_cents: 0)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(0, "EUR"))
    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)

    assert_equal(@category.overspent?(beginning_of_month), true)
  end

  test "spent_percentage is the ratio between the spent amount and the assigned amount in a given month" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(30000, "EUR"))

    assert_equal(@category.spent_percentage_in_month(beginning_of_month), (20000.to_f / 30000.to_f) * 100)
  end

  test "spent_percentage returns 0 when the assigned amount is 0 and its not overspent" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(0, "EUR"))

    assert_equal(@category.spent_percentage_in_month(beginning_of_month), 0.0)
  end

  test "spent_percentage returns 100 when overspent" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(5000, "EUR"))

    assert_equal(@category.spent_percentage_in_month(beginning_of_month), 100.0)
  end

  test "in_spending? returns true when spent_percentage is GREATER than 0%" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(30000, "EUR"))

    assert_equal(@category.in_spending?(beginning_of_month), true)
  end

  test "in_spending? returns false when spent_percentage is 100%" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(20000, "EUR"))

    assert_equal(@category.in_spending?(beginning_of_month), false)
  end

  test "spent_amount returns the sum of categorie's movements amounts as a Money object counting expenses as positive and income as negative" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -100_00, account: @account, category: @category, created_at: movement_date)
    Movement.create!(payer: "payer_2", amount_cents: 50_00, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(20000, "EUR"))

    assert_equal(@category.spent_amount_in_month(beginning_of_month), Money.new(50_00, "EUR"))
  end

  test "spent_amount returns 0 when there are no movements" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(20000, "EUR"))

    assert_equal(@category.spent_amount_in_month(beginning_of_month), Money.new(0, "EUR"))
  end

  test ".fully_spent? returns true when spent amount equals assigned_amount" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(200_00, "EUR"))
    Movement.create!(payer: "payer_1", amount_cents: -200_00, account: @account, category: @category, created_at: movement_date)

    assert_equal(@category.fully_spent?(beginning_of_month), true)
  end

  test ".fully_spent? returns false when spent amount does not equal assigned_amount" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(200_00, "EUR"))
    Movement.create!(payer: "payer_1", amount_cents: -300_00, account: @account, category: @category, created_at: movement_date)

    assert_equal(@category.fully_spent?(beginning_of_month), false)
  end

  test ".fully_spent? returns false when assigned amount is 0 and spent amount is 0" do
    beginning_of_month = Time.now.utc.beginning_of_month

    assert_equal(@category.fully_spent?(beginning_of_month), false)
  end

  test ".pristine? returns true when there's no assigned money nor spent" do
    beginning_of_month = Time.now.utc.beginning_of_month

    assert_equal(@category.pristine?(beginning_of_month), true)
  end

  test ".pristine? returns false when there's money assigned" do
    beginning_of_month = Time.now.utc.beginning_of_month
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(200_00, "EUR"))

    assert_equal(@category.pristine?(beginning_of_month), false)
  end

  test ".pristine? returns false when there's money spent" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -300_00, account: @account, category: @category, created_at: movement_date)

    assert_equal(@category.pristine?(beginning_of_month), false)
  end

  test ".available_to_spend_in returns the positive balance for a given month" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(200_00, "EUR"))
    Movement.create!(payer: "payer_1", amount_cents: -100_00, account: @account, category: @category, created_at: movement_date)

    assert_equal(@category.available_to_spend_in(beginning_of_month), Money.new(100_00, "EUR"))
  end

  test ".available_to_spend_in returns the accumulated available_to_spend from previous month" do
    movement_date = Time.now.utc
    beginning_of_current_month = movement_date.beginning_of_month
    beginning_of_previous_month = movement_date.prev_month.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -100_00, account: @account, category: @category, created_at: beginning_of_current_month)
    Movement.create!(payer: "payer_2", amount_cents: -200_00, account: @account, category: @category, created_at: beginning_of_previous_month)

    assert_equal(@category.available_to_spend_in(beginning_of_current_month), Money.new(-300_00, "EUR"))
  end

  test ".available_to_spend_in returns the accumulated available_to_spend from previous month minus its monthly assignment" do
    movement_date = Time.now.utc
    beginning_of_current_month = movement_date.beginning_of_month
    beginning_of_previous_month = movement_date.prev_month.beginning_of_month

    Movement.create!(payer: "payer_1", amount_cents: -100_00, account: @account, category: @category, created_at: beginning_of_current_month)
    Movement.create!(payer: "payer_2", amount_cents: -200_00, account: @account, category: @category, created_at: beginning_of_previous_month)
    MonthlyAssignment.create!(category: @category,
      start_date: beginning_of_current_month,
      end_date: beginning_of_current_month.next_month,
      amount: Money.new(100_00, "EUR"))

    assert_equal(@category.available_to_spend_in(beginning_of_current_month), Money.new(-200_00, "EUR"))
  end
end
