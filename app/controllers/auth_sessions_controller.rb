class AuthSessionsController < ApplicationController
  before_action :set_account, only: %i[create result]

  def create
    redirect_url = account_auth_session_result_url(@account, self)

    auth_session = AuthSession.create!(
      account_id: params[:account_id],
      redirect_url: redirect_url
    )

    redirect_to auth_session.url, allow_other_host: true
  end

  def result
    session_id = params[:ref].split('_').first
    auth_session = AuthSession.find_by(id: session_id)

    auth_session.update_with_provider_session_result!

    redirect_to account_url(@account)
  end

  private

  def set_account
    @account = Account.find(params[:account_id])
  end
end
