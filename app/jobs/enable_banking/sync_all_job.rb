class EnableBanking::SyncAllJob < ApplicationJob
  queue_as :default

  def perform
    BankConnection.where.not(session_id: nil).find_each do |connection|
      EnableBanking::TransactionSyncJob.perform_later(connection.id)
    end
  end
end
