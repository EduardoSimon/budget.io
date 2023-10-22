require "test_helper"

module AuthSessionTest
  class MockClient
    def initialize(session_result)
      @session_result = session_result || OpenBankingConnector::AuthSession.new(
        url: "url",
        id: SecureRandom.uuid,
        response: {params: "wadus"}
      )
    end

    def init_auth_session(institution_id:, internal_user_id:, redirect_url:)
      @session_result
    end

    def fetch_session_result(id)
      @session_result
    end
  end

  class SharedContext < ActiveSupport::TestCase
    def setup
      freeze_time
      @current_time = Time.now
      @uuid = SecureRandom.uuid
      @account = accounts(:one)
      @auth_session = auth_sessions(:in_progress)
      @connector_mock = Minitest::Mock.new
    end

    teardown do
      unfreeze_time
    end

    def subject(use_mock: false, session_result: nil)
      OpenBankingConnector.stub :new, use_mock ? @connector_mock : MockClient.new(session_result) do
        SecureRandom.stub :uuid, @uuid do
          yield
        end
      end
    end
  end

  class SuccessfulUpdateWithProviderTest < SharedContext
    def setup
      super
      @result = OpenBankingConnector::AuthSession.new(
        id: @auth_session.external_id,
        url: "url",
        accounts: ["external_account_id"],
        status: :succeeded
      )
    end

    test "it updates the auth_session with the result info" do
      @connector_mock.expect :fetch_session_result, @result, [@auth_session.external_id]

      subject(use_mock: true) do
        @auth_session.update_with_provider_session_result!
      end

      @auth_session.reload
      @account.reload

      @connector_mock.verify
      assert_equal("success", @auth_session.status)
      assert_equal("external_account_id", @auth_session.external_account_id)
      assert_equal("external_account_id", @account.external_account_id)
    end

    test "given a failure updating the account the session is left as it is" do
      error = ->(id, external_account_id) { raise StandardError }
      assert_raises(StandardError) do
        Account.stub :update!, error do
          subject(use_mock: true) do
            @auth_session.update_with_provider_session_result!
          end
        end
      end

      @auth_session.reload
      @account.reload

      assert_equal("in_progress", @auth_session.status)
      assert_nil(@auth_session.external_account_id)
      assert_nil(@account.external_account_id)
    end
  end

  class FailedAuthSessionTest < SharedContext
    def setup
      super
      @result = OpenBankingConnector::AuthSession.new(
        id: @auth_session.external_id,
        url: "url",
        accounts: [],
        status: :failed,
        response: {summary: "error"}
      )
    end

    test "marks the session as failed" do
      @connector_mock.expect :fetch_session_result, @result, [@auth_session.external_id]

      subject(use_mock: true) do
        @auth_session.update_with_provider_session_result!
      end

      assert_equal("failed", @auth_session.status)
      assert_equal({summary: "error"}, @auth_session.raw_response)

      @connector_mock.verify
    end

    test "raises an error due to invalid creds" do
      error_message = {}
      expected_error = '{"summary"=>"Authentication failed", "detail"=>"No active account found with the given credentials", "status_code"=>401}'
      begin
        AuthSession.create!(
          account: @account,
          external_id: "6d358dfe-00b1-4c1f-895d-45405591dadb",
          status: "in_progress",
          external_account_id: nil,
          external_institution_id: "wadus"
        )
      # We have to rescue from Exception because the API throws the Exception class for the error
      # rubocop:disable Lint/RescueException
      rescue Exception => e
        # rubocop:enable Lint/RescueException
        error_message = e.message
      end

      assert_equal(error_message, expected_error)
    end
  end

  class ModelParamsTest < SharedContext
    test "cannot be created without account_id" do
      subject do
        session = AuthSession.create(account_id: @account.id)
        assert_empty session.errors
      end
    end

    test "default status is in_progress" do
      subject do
        session = AuthSession.create(account_id: @account.id)
        assert_empty session.errors
        assert_equal "in_progress", session.status
      end
    end

    test "only allows valid status values" do
      subject do
        session = AuthSession.create(account_id: @account.id, status: "wadus")
        assert_empty session.errors
        assert_equal "in_progress", session.status
      end
    end
  end

  class ModelCreationTest < SharedContext
    def setup
      super
      @redirect_url = "localhost:3000/redirect"
      @result = OpenBankingConnector::AuthSession.new(
        id: @uuid,
        url: "url",
        accounts: [],
        response: {params: "wadus"}
      )
    end

    test "inits the OpenBanking provider session on creation" do
      @connector_mock.expect(
        :init_auth_session,
        @result
      ) do |args|
        assert_equal "SANDBOXFINANCE_SFIN0000", args[:institution_id]
        assert_equal "#{AuthSession.maximum(:id).to_i.next}_#{@current_time.to_i}", args[:internal_user_id]
        assert_equal @redirect_url, args[:redirect_url]
      end

      subject(use_mock: true) do
        @session = AuthSession.create!(
          account_id: @account.id,
          redirect_url: @redirect_url
        )
      end
    end

    test "updates the auth session with the result" do
      subject(session_result: @result, use_mock: false) do
        @session = AuthSession.create!(
          account_id: @account.id,
          redirect_url: @redirect_url
        )
      end

      @session.reload

      assert_equal(@result.url, @session.url)
      assert_equal(@result.id, @session.external_id)
      assert_equal("SANDBOXFINANCE_SFIN0000", @session.external_institution_id)
      assert_equal(@result.response, @session.raw_response)
    end

    test "creates auth session without calling open banking init session API" do
      assert_silent do
        AuthSession.create!(
          account: @account,
          external_id: "6d358dfe-00b1-4c1f-895d-45405591dadb",
          status: "in_progress",
          external_account_id: nil,
          external_institution_id: "wadus",
          skip_open_banking_session: true
        )
      end
    end
  end
end
