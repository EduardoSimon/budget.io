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

  test "creates an associated movement if set as transfer" do
    another_account = accounts(:two)
    movement_amount = -1500
    movement = Movement.create(account_id: @account.id, payer: "payer", amount_cents: movement_amount)

    assert_difference("Movement.count") do
      movement.update!(transfer_to_account_id: another_account.id)
    end

    contra_movement = Movement.order(created_at: :desc).first
    assert_equal contra_movement.amount_cents, movement_amount.abs
    assert_equal contra_movement.account_id, another_account.id
    assert_nil contra_movement.transfer_to_account_id
  end

  test "does not create an associated movement if the contra movement is already created" do
    another_account = accounts(:two)
    movement_amount = -1500
    contra_movement = Movement.create!(account_id: another_account.id,
                                       payer: "payer",
                                       amount_cents: movement_amount * -1)
    movement = Movement.create!(account_id: @account.id,
                                transfer_to_account_id: another_account.id,
                                payer: "payer",
                                amount_cents: movement_amount,
                                contra_movement_id: contra_movement.id)

    assert_no_difference("Movement.count") do
      movement.update!(transfer_to_account_id: another_account.id)
    end
  end
end
