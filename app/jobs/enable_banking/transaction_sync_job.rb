class EnableBanking::TransactionSyncJob < ApplicationJob
  queue_as :default

  def perform(bank_connection_id)
    connection = BankConnection.find(bank_connection_id)
    EnableBanking::TransactionSyncService.new(connection).call
  end
end
