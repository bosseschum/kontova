class CreateMixedCrateItems < ActiveRecord::Migration[8.1]
  def change
    create_table :mixed_crate_items do |t|
      t.references :mixed_crate, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
