class CreateGuestAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :guest_accesses do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :display_name
      t.string :email
      t.string :pin
      t.datetime :expires_at
      t.boolean :invoiced

      t.timestamps
    end
  end
end
