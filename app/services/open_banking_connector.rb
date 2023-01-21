class OpenBankingConnector
  AuthSession = Struct.new(:id, :status, :url, :accounts, :response, keyword_init: true) do
    def failed?
      status == :failed
    end
  end

  Account = Struct.new(:transactions, :balance, keyword_init: true)

  def initialize
    @client ||= client
  end

  def fetch_institutions_by_country(country)
    @client.generate_token
    @client.institution.get_institutions(country).map(&:deep_symbolize_keys)
  end

  def init_auth_session(institution_id:, internal_user_id:, redirect_url:)
    @client.generate_token

    # TODO {:summary=>"Authentication failed", :detail=>"Authentication credentials were not provided.", :status_code=>401}
    session_response = @client.init_session(
      redirect_url: redirect_url,
      institution_id: institution_id,
      reference_id: internal_user_id,
      user_language: "es"
    ).deep_symbolize_keys

    pp session_response
    AuthSession.new(id: session_response[:id], url: session_response[:link], accounts: [], response: session_response)
  end

  def fetch_session_result(id)
    response = @client.requisition.get_requisition_by_id(id).deep_symbolize_keys
    if response[:accounts].blank?
      return AuthSession.new(id: id, url: response[:link], accounts: [], status: :failed, response: response)
    end

    AuthSession.new(id: id, url: response[:link], accounts: response[:accounts], status: :succeeded)
  end

  def fetch_movements(external_account_id:)
    account = @client.account(external_account_id)

    # Fetch account metadata
    meta_data = account.get_metadata

    # Fetch details
    details = account.get_details

    # Fetch balances
    balance = account.get_balances["balances"].first["balanceAmount"]["amount"]
    Rails.logger.info(balance)

    # Fetch transactions
    transactions = account.get_transactions["transactions"]["booked"].map do |t|
      {
        id: t["transactionId"],
        date: t["bookingDate"],
        amount: t["transactionAmount"]["amount"],
        payer: t["debtorName"],
        description: t["remittanceInformationUnstructured"]
      }
    end

    Account.new(transactions: transactions, balance: balance)
  end

  def client
    ::Nordigen::NordigenClient.new(
      secret_id: ENV.fetch("OB_CLIENT_ID"),
      secret_key: ENV.fetch("OB_CLIENT_SECRET")
    )
  end
end
