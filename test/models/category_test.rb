require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  setup do
    @budget = budgets(:empty)
    @account = accounts(:one)
    @category = Category.create!(name: 'test', budget: @budget)
  end

  test "name is a mandatory parameter" do
    category = Category.create(name: "test")
    assert_empty category.errors[:name]
  end

  test "funded? returns true when the assigned amount is GREATER than the target amount" do
    @category.update!(assigned_amount_cents: 60000, target_amount_cents: 50000)

    assert_equal(@category.funded?, true)
  end

  test "funded? returns true when the assigned amount is EQUAL than the target amount" do
    @category.update!(assigned_amount_cents: 60000, target_amount_cents: 60000)

    assert_equal(@category.funded?, true)
  end

  test "funded? returns false when the assigned amount is LESS than the target amount" do
    @category.update!(assigned_amount_cents: 10000, target_amount_cents: 60000)

    assert_equal(@category.funded?, false)
  end

  test "overspent? returns true when the spent amount is GREATER than the assigned_amount_cents" do
    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category)

    @category.update!(assigned_amount_cents: 10000, target_amount_cents: 60000)

    assert_equal(@category.overspent?, true)
  end

  test "overspent? returns false when the spent amount is SMALLER than the assigned_amount_cents" do
    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category)

    @category.update!(assigned_amount_cents: 30000, target_amount_cents: 60000)

    assert_equal(@category.overspent?, false)
  end

  test "overspent? returns false when the spent amount is EQUAL to the the assigned_amount_cents" do
    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category)

    @category.update!(assigned_amount_cents: 20000, target_amount_cents: 60000)

    assert_equal(@category.overspent?, false)
  end

  test "spent_percentage is the ratio between the spent amount and the assigned amount" do
    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category)

    @category.update!(assigned_amount_cents: 30000)

    assert_equal(@category.spent_percentage, (20000.to_f / 30000.to_f) * 100)
  end

  test "in_spending? returns true when spent_percentage is GREATER than 0%" do
    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category)

    @category.update!(assigned_amount_cents: 30000)

    assert_equal(@category.in_spending?, true)
  end

  test "in_spending? returns false when spent_percentage is 100%" do
    movement_1 = Movement.create!(payer: "payer_1", amount_cents: -10000, account: @account, category: @category)
    movement_2 = Movement.create!(payer: "payer_2", amount_cents: -10000, account: @account, category: @category)

    @category.update!(assigned_amount_cents: 20000)

    assert_equal(@category.in_spending?, false)
  end
end
