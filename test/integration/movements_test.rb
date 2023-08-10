require "test_helper"

class MovementsTest < ActionDispatch::IntegrationTest
  setup do
    @account = create(:account)
  end

  test "a movement can be created" do
    movement_params = attributes_for(:movement)

    get "/movements/new"

    assert_response :success
    post "/movements",
      params: {
        movement: movement_params.merge(account_id: @account.id)
      }

    assert_response :redirect
    follow_redirect!
    assert_response :success
  end
end
