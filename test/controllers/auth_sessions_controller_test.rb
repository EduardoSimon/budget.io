require "test_helper"
require "test_helpers/mock_client"

class AuthSessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @account = accounts(:one)
    @auth_session = auth_sessions(:in_progress)
  end

  test "creates an account auth session" do
    OpenBankingConnector.stub :new, MockClient.new do
      assert_difference("AuthSession.count") do
        post account_auth_sessions_url(@account), params: {account_id: @account.id}
      end
    end

    assert_redirected_to "url1"
  end

  test "receives the open banking callback confirming the session" do
    OpenBankingConnector.stub :new, MockClient.new do
      get account_auth_session_result_url(@account, @auth_session),
        params: {account_id: @account.id, ref: @auth_session.id}
    end

    assert_redirected_to account_url(@account)
  end
end
