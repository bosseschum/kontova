class CreatePurchases < ActiveRecord::Migration[8.1]
  def change
    create_table :purchases do |t|
      t.references :product, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :price_per_unit_cents, null: false
      t.string :note
      t.date :purchased_on, null: false
      t.timestamps
    end
  end
end
