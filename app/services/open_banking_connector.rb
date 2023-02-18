class OpenBankingConnector
  AuthSession = Struct.new(:id, :status, :url, :accounts, :response, keyword_init: true) do
    def failed?
      status == :failed
    end
  end

  Account = Struct.new(:transactions, :balance, keyword_init: true)

  def fetch_institutions_by_country(country)
    client.institution.get_institutions(country).map(&:deep_symbolize_keys)
  end

  def init_auth_session(institution_id:, internal_user_id:, redirect_url:)
    # TODO {:summary=>"Authentication failed", :detail=>"Authentication credentials were not provided.", :status_code=>401}
    session_response = client.init_session(
      redirect_url: redirect_url,
      institution_id: institution_id,
      reference_id: internal_user_id,
      user_language: "es"
    ).deep_symbolize_keys

    pp session_response
    AuthSession.new(id: session_response[:id], url: session_response[:link], accounts: [], response: session_response)
  end

  def fetch_session_result(id)
    response = client.requisition.get_requisition_by_id(id).deep_symbolize_keys
    if response[:accounts].blank?
      return AuthSession.new(id: id, url: response[:link], accounts: [], status: :failed, response: response)
    end

    AuthSession.new(id: id, url: response[:link], accounts: response[:accounts], status: :succeeded)
  end

  def fetch_movements(external_account_id:)
    account = client.account(external_account_id)

    balances = account.get_balances["balances"]

    Rails.logger.info({
      balances: balances,
      message: "Requested account balances for account #{external_account_id}",
      external_account_id: external_account_id
    })

    raise StandardError.new("balances object is nil in account") if balances.nil?

    main_balance = balances.first["balanceAmount"]

    raise StandardError.new({message: "balances object was empty", params: main_balance}) if main_balance.nil?

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

    Account.new(transactions: transactions, balance: main_balance["amount"])
  end

  def client
    @client ||= ::Nordigen::NordigenClient.new(
      secret_id: ENV.fetch("OB_CLIENT_ID"),
      secret_key: ENV.fetch("OB_CLIENT_SECRET")
    )

    if auth_token_invalid?
      @token_response = {
        token_response: @client.generate_token,
        last_fetch_timestamp: Time.now.to_i
      }
    end

    @client
  end

  def auth_token_invalid?
    return true if @token_response.nil?
    @token_response[:last_fetch_timestamp] + @token_response.dig(:token_response, :access_expires) <= Time.now.to_i
  end
end
