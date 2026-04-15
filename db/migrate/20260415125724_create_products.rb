class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :price_cents, null: false
      t.boolean :active, default: true, null: false
      t.timestamps
    end
  end
end
