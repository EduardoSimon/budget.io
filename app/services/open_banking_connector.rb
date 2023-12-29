class OpenBankingConnector
  AuthSession = Struct.new(:id, :status, :url, :accounts, :response, keyword_init: true) do
    def failed?
      status == :failed
    end
  end

  AccountResponse = Struct.new(:transactions, :balance, :currency, keyword_init: true)

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

    Rails.logger.info(session_response)
    AuthSession.new(id: session_response[:id], url: session_response[:link], accounts: [], response: session_response)
  end

  def fetch_session_result(id)
    response = client.requisition.get_requisition_by_id(id).deep_symbolize_keys
    if response[:accounts].blank?
      return AuthSession.new(id: id, url: response[:link], accounts: [], status: :failed, response: response)
    end

    AuthSession.new(id: id, url: response[:link], accounts: response[:accounts], status: :succeeded)
  end

  def fetch_movements(account:)
    external_account_id = account.external_account_id
    external_account = client.account(external_account_id)

    balances_response = external_account.get_balances.deep_symbolize_keys

    raise StandardError.new(balances_response.to_json) if balances_response[:status_code] && balances_response[:status_code] >= 400

    balances = balances_response[:balances]

    Rails.logger.info({
      balances: balances,
      message: "Requested account balances for account #{external_account_id}",
      external_account_id: external_account_id
    })

    raise StandardError.new("balances object is nil in account") if balances.nil?

    main_balance = settled_amount_from(balances)

    Rails.logger.info({balances:})

    raise StandardError.new({message: "balances object was empty", params: balances}) if main_balance.nil?

    transactions_response = get_transactions_response(external_account:, account:)

    transactions = transactions_response[:transactions]
    raise StandardError.new({message: "No transactions object found"}) unless transactions

    booked_transactions = transactions[:booked]
    raise StandardError.new({message: "No booked transactions object found"}) unless booked_transactions

    transactions = booked_transactions.map do |t|
      {
        id: t[:transactionId],
        date: t[:bookingDate],
        amount: t[:transactionAmount][:amount].to_f,
        payer: t[:debtorName],
        description: t[:remittanceInformationUnstructured]
      }
    end

    AccountResponse.new(transactions: transactions, balance: main_balance[:amount].to_f, currency: main_balance[:currency])
  end

  SETTLED_BALANCE_TYPES = ["interimBooked"]

  def settled_amount_from(balances)
    balances.find { |b| SETTLED_BALANCE_TYPES.include?(b[:balanceType]) }[:balanceAmount]
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

  def get_transactions_response(external_account:, account:)
    last_movement_date = account
      .movements
      .order(:created_at)
      .last&.created_at

    date_from = (last_movement_date || 4.months.ago).strftime("%F")
    date_to = Time.now.strftime("%F")

    external_account.get_transactions(
      date_from:,
      date_to:
    ).deep_symbolize_keys
  end
end
