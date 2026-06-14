module EnableBanking
  class TransactionSyncService
    def initialize(bank_connection)
      @connection = bank_connection
      @client = EnableBanking::Client.new
    end

    def call
      @connection.bank_accounts.each do |account|
        begin
          sync_account(account)
        rescue RuntimeError => e
          Rails.logger.error("Failed to sync account #{account.uid}: #{e.message}")
        end
      end
    end

    private

    def sync_account(account)
      continuation_key = nil

      loop do
        params = "session_id=#{@connection.session_id}"
        params += "&continuation_key=#{continuation_key}" if continuation_key

        result = @client.get("/accounts/#{account.uid}/transactions?#{params}")

        result["transactions"].each do |txn|
          import_transaction(account, txn)
        end

        continuation_key = result["continuation_key"]
        break if continuation_key.nil?
      end
    end

    def import_transaction(account, txn)
      external_id = txn["entry_reference"] || txn["transaction_id"]
      return if external_id.blank?

      account.bank_transactions.find_or_create_by!(external_id: external_id) do |t|
        t.amount_cents = (txn.dig("transaction_amount", "amount").to_f * 100).round
        t.currency     = txn.dig("transaction_amount", "currency") || account.currency
        t.booked_at    = txn["booking_date"]
        t.value_date   = txn["value_date"]
        t.description  = txn["remittance_information_unstructured"] ||
                         txn["creditor_name"] ||
                         txn["debtor_name"]
        t.raw          = txn
      end
    end
  end
end
