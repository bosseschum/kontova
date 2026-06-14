class CreateBankConnections < ActiveRecord::Migration[8.1]
  def change
    create_table :bank_connections do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :authorization_id, null: false
      t.string :session_id
      t.string :bank_name, null: false
      t.string :bic
      t.datetime :consent_expires_at

      t.timestamps
    end

    add_index :bank_connections, :authorization_id, unique: true
    add_index :bank_connections, :session_id, unique: true, where: "session_id IS NOT NULL"
  end
end
