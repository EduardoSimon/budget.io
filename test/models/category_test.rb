require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  test "name is a mandatory parameter" do
    category = Category.create(name: "test")
    assert_empty category.errors[:name]
  end
end
