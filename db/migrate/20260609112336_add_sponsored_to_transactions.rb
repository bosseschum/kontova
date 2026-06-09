class AddSponsoredToTransactions < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :sponsored, :boolean
    add_column :transactions, :original_amount_cents, :integer
  end
end
