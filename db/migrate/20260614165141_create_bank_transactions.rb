class CreateBankTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :bank_transactions do |t|
      t.references :bank_account, null: false, foreign_key: true
      t.string :external_id, null: false
      t.integer :amount_cents, null: false
      t.string :currency, null: false
      t.date :booked_at
      t.date :value_date
      t.string :description
      t.jsonb :raw, default: {}

      t.timestamps
    end

    add_index :bank_transactions, :external_id, unique: true
    add_index :bank_transactions, :booked_at
    add_index :bank_transactions, :raw, using: :gin
  end
end
