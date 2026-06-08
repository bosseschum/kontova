class RemoveOrganizationColumnsFromMembers < ActiveRecord::Migration[8.1]
  def change
    remove_column :members, :organization_id
    remove_column :members, :role
    remove_column :members, :pin
    remove_column :members, :pays_fee
    remove_column :members, :lives_on_site
  end
end
