class CreateInventoryCounts < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_counts do |t|
      t.references :product, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: true
      t.integer :actual_quantity, null: false
      t.date :counted_on, null: false
      t.string :note
      t.timestamps
    end
  end
end
