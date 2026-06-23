class MakeTransactionPurchaserPolymorphic < ActiveRecord::Migration[8.1]
  def change
    add_column :transactions, :purchaser_type, :string
    rename_column :transactions, :member_id, :purchaser_id

    up_only { Transaction.update_all(purchaser_type: 'Member') }
  end
end
