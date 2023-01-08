require "test_helper"

class MovementTest < ActiveSupport::TestCase
  def setup
    @account = accounts(:one)
    @category = categories(:funded)
  end

  test "requires a payer" do
    movement = Movement.create(account_id: @account.id)
    assert_includes movement.errors[:payer], "can't be blank"
  end

  test "requires an amount" do
    movement = Movement.create(account_id: @account.id, payer: "payer")
    assert_includes movement.errors[:amount], "can't be blank"
  end

  test "requires a decimal amount" do
    movement = Movement.create(account_id: @account.id, payer: "payer", amount: "wadus")
    assert_includes movement.errors[:amount], "is not a number"
  end

  test "has no category by default" do
    movement = Movement.create(account_id: @account.id, payer: "payer", amount: 10.0)
    assert_nil movement.category
  end

  test "can be assigned to a category" do
    movement = Movement.create(account_id: @account.id, payer: "payer", amount: 10.0)
    movement.category = @category
    assert_equal movement.category.id, @category.id
  end

  test "is a credit when the amount is negative" do
    movement = Movement.create(account_id: @account.id, payer: "payer", amount: -10.00)
    assert movement.credit?
    refute movement.debit?
  end

  test "is a debit when the amount is 0" do
    movement = Movement.create(account_id: @account.id, payer: "payer", amount: 0.00)
    refute movement.credit?
    assert movement.debit?
  end

  test "is a debit when the amount is greater than 0" do
    movement = Movement.create(account_id: @account.id, payer: "payer", amount: 0.00)
    refute movement.credit?
    assert movement.debit?
  end
end
