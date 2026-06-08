class CreateOrganizationMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :organization_memberships do |t|
      t.references :member, null: false, foreign_key: true
      t.references :organization, null: false, foreign_key: true
      t.integer :role, null: false, default: 0
      t.string :pin
      t.boolean :pays_fee, default: true, null: false
      t.boolean :lives_on_site, default: false, null: false
      t.timestamps
    end

    add_index :organization_memberships, [ :member_id, :organization_id ], unique: true
  end
end
