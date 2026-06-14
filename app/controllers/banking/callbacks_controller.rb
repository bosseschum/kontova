module Banking
  class CallbacksController < ApplicationController
    skip_before_action :authenticate_member!
    skip_before_action :set_organization

    def show
      if params[:error].present?
        Rails.logger.error("Enable Banking callback error: #{params[:error]}")
        return redirect_to root_path, alert: "Bank authorization failed: #{params[:error]}"
      end

      code = params[:code]
      return redirect_to root_path, alert: "Missing authorization code." if code.blank?

      session_data = EnableBanking::Client.new.post("/sessions", { code: code })

      connection = BankConnection.find_by!(authorization_id: params[:state])
      connection.update!(session_id: session_data["session_id"])

      session_data["accounts"].each do |account|
        connection.bank_accounts.find_or_create_by!(uid: account["uid"]) do |a|
          a.iban     = account.dig("account_id", "iban")
          a.product  = account["product"]
          a.currency = account["currency"] || "EUR"
        end
      end

      EnableBanking::TransactionSyncService.new(connection).call

      redirect_to root_path, notice: "Bank connected — #{connection.bank_accounts.count} accounts, #{connection.bank_accounts.joins(:bank_transactions).count} transactions imported."
    end
  end
end
