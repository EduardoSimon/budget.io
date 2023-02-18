  class MockClient
    def init_auth_session(institution_id:, internal_user_id:, redirect_url:)
      OpenBankingConnector::AuthSession.new(url: "url1", id: "id")
    end

    def fetch_session_result(id)
      OpenBankingConnector::AuthSession.new(url: "url1", id: "id", accounts: ["account1"])
    end
  end