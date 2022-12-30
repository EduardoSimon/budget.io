class OpenBankingConnector
  AuthSession = Struct.new(:id, :url, :accounts, keyword_init: true)

  class << self
    def fetch_institutions_by_country(country)
      client.generate_token
      client.institution.get_institutions(country).map(&:deep_symbolize_keys)
    end

    def init_auth_session(institution_id:, internal_user_id:, redirect_url:)
      session = client.init_session(
        redirect_url: redirect_url,
        institution_id: institution_id,
        reference_id: internal_user_id,
        user_language: "en",
        account_selection: true
      ).deep_symbolize_keys

      AuthSession.new(id: session[:id], url: session[:link], accounts: [])
    end

    def fetch_session_result(id)
      response = client.requisition.get_requisition_by_id(requisition_id).deep_symbolize_keys
      AuthSession.new(id: id, url: response[:link], accounts: response[:accounts])
    end

    def client
      @client ||= ::Nordigen::NordigenClient.new(
        secret_id: ENV.fetch("OB_CLIENT_ID"),
        secret_key: ENV.fetch("OB_SECRET_KEY")
      )
    end
  end
end
