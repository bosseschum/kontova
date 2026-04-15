class CreateTransactions < ActiveRecord::Migration[8.1]
  def change
    create_table :transactions do |t|
      t.references :member, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.integer :kind, null: false
      t.integer :quantity, default: 1
      t.string :note
      t.timestamps
    end
  end
end
