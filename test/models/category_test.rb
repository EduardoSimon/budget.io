require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @budget = budgets(:empty)
    @account = accounts(:one)
    @category = Category.create!(name: 'test', budget: @budget)
  end

  teardown do
    @category.destroy!
  end

  test "name is a mandatory parameter" do
    category = Category.create(name: "test")
    assert_empty category.errors[:name]
  end

  test "funded? returns true when the assigned amount in a month is GREATER than the target amount" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(60000, "EUR")) 

    @category.update!(target_amount_cents: 50000)

    assert_equal(@category.funded?(beginning_of_month), true)
  end

  test "funded? returns true when the assigned amount in a month is EQUAL than the target amount" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(50000, "EUR")) 

    @category.update!(target_amount_cents: 50000)

    assert_equal(@category.funded?(beginning_of_month), true)
  end

  test "funded? returns false when the assigned amount in a month is LESS than the target amount" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)

    @category.update!(target_amount_cents: 60000)

    assert_equal(@category.funded?(beginning_of_month), false)
  end

  test "overspent? returns true when the spent amount is GREATER than the assigned amount in a month" do
    movement_date = Time.now.utc 
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(10000, "EUR")) 

    assert_equal(@category.overspent?(beginning_of_month), true)
  end

  test "overspent? returns false when the spent amount is SMALLER than the assigned amount in a month" do
    movement_date = Time.now.utc 
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(40000, "EUR")) 

    assert_equal(@category.overspent?(beginning_of_month), false)
  end

  test "overspent? returns false when the spent amount is EQUAL to the the assigned_amount_cents" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(20000, "EUR")) 

    assert_equal(@category.overspent?(beginning_of_month), false)
  end

  test "overspent? returns false when the target_amount is 0 and the assignment is 0 and activity is greater than 0"  do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    @category.update!(target_amount_cents: 0)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(0, "EUR")) 

    assert_equal(@category.overspent?(beginning_of_month), false)
  end

  test "overspent? returns true true the target_amount is 0 and the assignment is 0 and activity is greater than 0"  do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    @category.update!(target_amount_cents: 0)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(0, "EUR")) 
    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)

    assert_equal(@category.overspent?(beginning_of_month), true)
  end

  test "spent_percentage is the ratio between the spent amount and the assigned amount in a given month" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(30000, "EUR")) 

    assert_equal(@category.spent_percentage_in_month(beginning_of_month), (20000.to_f / 30000.to_f) * 100)
  end

  test "in_spending? returns true when spent_percentage is GREATER than 0%" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(30000, "EUR")) 

    assert_equal(@category.in_spending?(beginning_of_month), true)
  end

  test "in_spending? returns false when spent_percentage is 100%" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(20000, "EUR")) 

    assert_equal(@category.in_spending?(beginning_of_month), false)
  end

  test "spent_amount returns the sum of categorie's movements amounts as a Money object counting expenses as positive and income as negative" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -100_00, account: @account, category: @category, created_at: movement_date)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: 50_00, account: @account, category: @category, created_at: movement_date)
    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(20000, "EUR")) 

    assert_equal(@category.spent_amount_in_month(beginning_of_month), Money.new(50_00, "EUR"))
  end

  test "spent_amount returns 0 when there are no movements" do
    movement_date = Time.now.utc
    beginning_of_month = movement_date.beginning_of_month

    MonthlyAssignment.create!(category: @category, start_date: beginning_of_month, end_date: beginning_of_month.next_month, amount: Money.new(20000, "EUR")) 

    assert_equal(@category.spent_amount_in_month(beginning_of_month), Money.new(0, "EUR"))
  end
end
