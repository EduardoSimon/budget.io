require "test_helper"

class MonthlyAssignmentTest < ActiveSupport::TestCase
  def setup
    @category = categories(:funded)
  end

  test "requires a category" do
    assignment = MonthlyAssignment.create
    assert_equal assignment.errors[:category], ["must exist"]
  end

  test "requires a money object" do
    assignment = MonthlyAssignment.create(category: @category)
    assert_equal assignment.errors[:amount], ["is not a number"]
  end

  test "requires a start_date" do
    assignment = MonthlyAssignment.create

    assert_equal assignment.errors[:start_date], ["can't be blank"]
  end

  test "requires an end_date" do
    assignment = MonthlyAssignment.create

    assert_includes assignment.errors[:end_date], "can't be blank"
  end

  test "start_date needs to be smaller than end_date" do
    start_date = Date.new(2023, 2, 1)
    end_date = Date.new(2023, 1, 1)
    assignment = MonthlyAssignment.create(
      category: @category,
      amount: Money.new(100, "EUR"),
      start_date: start_date,
      end_date: end_date
    )

    assert_equal assignment.errors[:end_date],
      ["must be greater than #{start_date.strftime("%F")}"]
  end
end
