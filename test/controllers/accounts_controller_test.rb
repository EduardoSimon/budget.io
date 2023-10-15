require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:one)
    @budget = budgets(:empty)
    @institution = institutions(:revolut)
  end

  test "should get index" do
    get accounts_url
    assert_response :success
  end

  test "should get new" do
    get new_account_url
    assert_response :success
  end

  test "should create account" do
    assert_difference("Account.count") do
      post accounts_url, params: {account: {name: @account.name, institution_id: @institution.id, budget_id: @budget.id}}
    end

    assert_redirected_to account_url(Account.last)
  end

  test "should show account" do
    get account_url(@account)
    assert_response :success
  end

  test "should get edit" do
    get edit_account_url(@account)
    assert_response :success
  end

  test "should update account" do
    patch account_url(@account), params: {account: {iban: @account.iban, name: @account.name}}
    assert_redirected_to account_url(@account)
  end

  test "should destroy account" do
    assert_difference("Account.count", -1) do
      delete account_url(@account)
    end

    assert_redirected_to accounts_url
  end

  class ShowAccountsTest < ActionDispatch::IntegrationTest
    test "given an account that needs to be reconciled shows a notice with a button to reconcile the movement" do
      account = create(:account, reported_balance: Money.new("2000_00", "EUR"))
      create(:movement, amount: Money.new("3000_00", "EUR"), account_id: account.id)

      get accounts_url
      assert_select "p", /Your account needs to be reconcile to match the reported balance and the computed balance./
      assert_select "p", /Reported balance: €2,000/
      assert_select "p", /Compute balance: €3,000/
      assert_select "a", href: /\/movements\/new/
    end

    test "given an account that DOES NOT need to be reconciled DO NOT show a notice with a button to reconcile the movement" do
      account = create(:account, reported_balance: Money.new("2000_00", "EUR"))
      create(:movement, amount: Money.new("2000_00", "EUR"), account_id: account.id)

      get accounts_url
      assert_select "p", {count: 0, text: /Your account needs to be reconcile to match the reported balance and the computed balance./}
      assert_select "p", {count: 0, text: /Reported balance: €2,000/}
      assert_select "p", {count: 0, text: /Compute balance: €3,000/}
    end
  end
end
