require "test_helper"

class BudgetsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @budget = Budget.create!(title: "test")
  end

  test "should get index" do
    get budgets_url
    assert_response :success
  end

  test "should get new" do
    get new_budget_url
    assert_response :success
  end

  test "should create budget" do
    assert_difference("Budget.count") do
      post budgets_url, params: {budget: {title: @budget.title}}
    end

    assert_redirected_to budget_url(Budget.last)
  end

  test "should show budget with its categories" do
    get budget_url(@budget)
    assert_response :success
  end

  test "should get edit" do
    get edit_budget_url(@budget)
    assert_response :success
  end

  test "should update budget" do
    patch budget_url(@budget), params: {budget: {title: @budget.title}}
    assert_redirected_to budget_url(@budget)
  end

  test "should destroy budget" do
    assert_difference("Budget.count", -1) do
      delete budget_url(@budget)
    end

    assert_redirected_to budgets_url
  end
  class ShowBudgetTests < ActionDispatch::IntegrationTest
    setup do
      @budget = Budget.create!(title: "test")
    end

    test "given a budget with accounts that need to be reconciled" do
      account = create(:account, budget_id: @budget.id, reported_balance: Money.new("2000_00", "EUR"))
      create(:movement, amount: Money.new("3000_00", "EUR"), account_id: account.id)

      get budget_url(@budget)
      assert_select "p", /There's a mismatch in your any of the/
      assert_select "a[href=\"/accounts\"]"
    end

    test "given a budget with accounts that need DO NOT need to be reconciled" do
      account = create(:account, budget_id: @budget.id, reported_balance: Money.new("3000_00", "EUR"))
      create(:movement, amount: Money.new("3000_00", "EUR"), account_id: account.id)

      get budget_url(@budget)
      assert_select "p", {count: 0, text: /There's a mismatch in your any of the/}
      assert_select "a", {count: 0, text: "a[href=\"/accounts\"]"}
    end
  end
end
