class CreateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :requests do |t|
      t.references :member, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.text :description, null: false
      t.integer :amount_cents
      t.integer :status, null: false, default: 0
      t.text :note
      t.timestamps
    end
  end
end
