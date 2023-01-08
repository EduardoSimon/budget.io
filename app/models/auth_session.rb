class AuthSession < ApplicationRecord
  belongs_to :account
  before_create :set_default_status
  before_create :init_open_banking_provider_session
  serialize :raw_response, JsonbSerializer

  IN_PROGRESS_STATUS = "in_progress"
  FAILED_STATUS = "failed"
  SUCCESS_STATUS = "success"

  def update_with_provider_session_result!
    result = OpenBankingConnector.new.fetch_session_result(external_id)

    if result.failed?
      update!(status: FAILED_STATUS, raw_response: result.response)
      return
    end

    external_account_id = result.accounts.first

    ActiveRecord::Base.transaction do
      update!(status: SUCCESS_STATUS, external_account_id: external_account_id)
      Account.update!(account_id, external_account_id: external_account_id)
    end
  end

  private

  def set_default_status
    self.status = IN_PROGRESS_STATUS
  end

  def init_open_banking_provider_session
    institution_id = "SANDBOXFINANCE_SFIN0000"

    session_response = OpenBankingConnector.new.init_auth_session(
      institution_id: institution_id,
      internal_user_id: AuthSession.maximum(:id).to_i.next,
      redirect_url: redirect_url
    )

    self.url = session_response.url
    self.external_id = session_response.id
    self.external_institution_id = institution_id
    self.raw_response = session_response.response
  end
end
